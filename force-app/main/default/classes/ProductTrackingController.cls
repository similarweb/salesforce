public with sharing class ProductTrackingController {
	/**
    * @author Elnur Alibaev
    * @date 22/07/2025
    * @description Get solutions and skus hierarchy for product tracking
    * @param String recordId - oppId from which the flow was initiated
    * @return Map of required for the productTracking lwc details
    */
	@AuraEnabled(cacheable = false)
	public static Map<String, Object> getData(String recordId) {
		List<ParentPDTO> solutions = new List<ParentPDTO>();

		Opportunity opp = [
				SELECT Id, Name, Pricebook2Id, Type, Account.Status__c, Account.ARR__c,
						Opportunity_Subtype__c, RecordType.Name
				FROM Opportunity
				WHERE Id =: recordId
		];
		List<Product2> parents = getParentProducts(opp.RecordType.Name);

		Map<String, Decimal> productToPrice = getPrices(parents, opp.Pricebook2Id);
		Map<String, OpportunityLineItem> productToOppProduct = getExistingProducts(opp.Id);

		for (Product2 p : parents) {
			solutions.add(new ParentPDTO(p, productToPrice, productToOppProduct));
		}

		Map<String, Object> result = new Map<String, Object>{
		'solutions' => solutions,
		'type' => opp.Type,
		'subType' => opp.Opportunity_Subtype__c,
		'acquiredCompany' => opp.RecordType.Name.equals('Acquired Company'),
		'defaultSubType' => getSubTypeBasedOnProduct(productToOppProduct.size() > 0 ? new List<String>(productToOppProduct.keySet())[0] : null),
		'isAccActive' => opp.Account.Status__c == 'Active' && opp.Account.ARR__c > 0,
		'subTypeOptions' => getPicklistOptions('Opportunity', 'Opportunity_Subtype__c'),
		'purchaseMotionOptions' => getPicklistOptions('Product2', 'Purchase_Motion_Options__c')
		};

		return result;
	}

	/**
    * @author Elnur Alibaev
    * @date 22/07/2025
    * @description Save/Remove solutions and skus
    * @param String jsonInput - updated solutions and skus, oppId and subType
    * @return String saving result message
    */
	@AuraEnabled(cacheable = false)
	public static String saveData(String jsonInput) {
		Map<String, String> input = (Map<String, String>) JSON.deserialize(jsonInput, Map<String, String>.class);

		String oppId = input.get('oppId'), subType = input.get('subType');
		List<ParentPDTO> solutions = (List<ParentPDTO>) JSON.deserialize(input.get('solutions'), List<ParentPDTO>.class);

		List<OpportunityLineItem> newProducts = new List<OpportunityLineItem>();
		List<String> oldProducts = new List<String>();

		for (ParentPDTO s : solutions) {
			if (s.open) {

				for (ProductDTO p : s.products.get(subType)) {
					if (p.selected) {
						if (String.isBlank(p.oppProductId)) {
							newProducts.add(new OpportunityLineItem(
									Product2Id = p.id,
									OpportunityId = oppId,
									UnitPrice = p.unitPrice,
									Purchase_Motion__c = p.purchaseMotion,
									Quantity = 1
							));
						}
					} else if (p.initSelected) {
						oldProducts.add(p.id);
					}
				}

				if (String.isBlank(s.oppProductId)) {
					newProducts.add(new OpportunityLineItem(
							Product2Id = s.id,
							OpportunityId = oppId,
							UnitPrice = s.unitPrice,
							Quantity = 1
					));
				}
			} else {
				if (String.isNotBlank(s.oppProductId)) {
					oldProducts.add(s.id);
				}

				for (ProductDTO p : s.products.get(subType)) {
					if (p.initSelected) {
						oldProducts.add(p.id);
					}
				}
			}

			oldProducts.addAll(s.extractAllProductIdsExceptForSubType(subType));
		}

		try {
			update new Opportunity(Id = oppId, Opportunity_Subtype__c = subType, UpdatedByNextStageFlow__c = true);
			delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: oppId AND Product2Id IN: oldProducts];
			insert newProducts;
			updateProductTracking(new List<String>{oppId});
			update new Opportunity(Id = oppId, UpdatedByNextStageFlow__c = false);
		} catch (Exception e) {
			return e.getMessage();
		}

		return 'Success';
	}

	private static List<Product2> getParentProducts(String recordType) {
		if (recordType.equals('Acquired Company')) {
			return [
					SELECT Id, Name, Family, New_Business__c, Upsell_Existing_Account__c,
							Upsell_New_Paying_Account__c, Renewal__c, IsActive, Acquired_Company__c,
							(SELECT Id, Name, Family, New_Business__c, Upsell_Existing_Account__c, Upsell_New_Paying_Account__c,
									 Renewal__c, IsActive, Purchase_Motion_Options__c, Acquired_Company__c
							FROM Child_Products__r
							WHERE Product_Tracking__c = true
							AND ProductType__c = 'SKU'
							AND Acquired_Company__c = true
							ORDER BY Sort_Order__c)
					FROM Product2
					WHERE Product_Tracking__c = true
					AND Product2.ProductType__c = 'Solution / Delivery'
					AND IsActive = true
					AND Acquired_Company__c = true
					ORDER BY Sort_Order__c
			];
		} else {
			return [
					SELECT Id, Name, Family, New_Business__c, Upsell_Existing_Account__c,
							Upsell_New_Paying_Account__c, Renewal__c, IsActive, Acquired_Company__c,
							(SELECT Id, Name, Family, New_Business__c, Upsell_Existing_Account__c, Upsell_New_Paying_Account__c,
									 Renewal__c, IsActive, Purchase_Motion_Options__c, Acquired_Company__c
							FROM Child_Products__r
							WHERE Product_Tracking__c = true
							AND ProductType__c = 'SKU'
							ORDER BY Sort_Order__c)
					FROM Product2
					WHERE Product_Tracking__c = true
					AND Product2.ProductType__c = 'Solution / Delivery'
					AND IsActive = true
					ORDER BY Sort_Order__c
			];
		}
	}

	private static Map<String, Decimal> getPrices(List<Product2> products, String pricebookId) {
		Map<String, Decimal> productToPrice = new Map<String, Decimal>();
		Set<String> ids = new Set<String>();

		for (Product2 p : products) {
			for (Product2 c : p.Child_Products__r) {
				ids.add(c.Id);
			}
			ids.add(p.Id);
		}

		List<PricebookEntry> entries = [
				SELECT Id, Product2Id, UnitPrice
				FROM PricebookEntry
				WHERE Pricebook2Id =: pricebookId AND Product2Id IN: ids AND IsActive = true
		];

		for (PricebookEntry e : entries) {
			productToPrice.put(e.Product2Id, e.UnitPrice);
		}

		return productToPrice;
	}

	private static Map<String, OpportunityLineItem> getExistingProducts(String oppId) {
		Map<String, OpportunityLineItem> productToOppProduct = new Map<String, OpportunityLineItem>();
		List<OpportunityLineItem> oppProducts = [
				SELECT Id, Product2Id, Purchase_Motion__c, Product2.Purchase_Motion_Options__c
				FROM OpportunityLineItem
				WHERE OpportunityId =: oppId AND Display_On_Opportunity__c = true
		];

		for (OpportunityLineItem p : oppProducts) {
			productToOppProduct.put(p.Product2Id, p);
		}

		return productToOppProduct;
	}

	private static String getSubTypeBasedOnProduct(String productId) {
		if (productId == null) {
			return '';
		}

		Product2 p = [
				SELECT Id, New_Business__c, Upsell_Existing_Account__c, Upsell_New_Paying_Account__c, Renewal__c
				FROM Product2
				WHERE Id =: productId
		];

		String subType = p.New_Business__c ? 'New Sale' : (
		p.Upsell_New_Paying_Account__c ? 'Upsell (New Paying Account)' : (
		p.Upsell_Existing_Account__c ? 'Upsell (Existing Account)' : (
		p.Renewal__c ? 'Renewal' : null
		)));

		return subType;
	}

	public static List<Map<String, String>> getPicklistOptions(String objectName, String fieldName) {
		List<Map<String, String>> options = new List<Map<String, String>>();

		for( Schema.PicklistEntry pickListVal : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap()
				.get(fieldName).getDescribe().getPicklistValues()){
			options.add(new Map<String, String>{
			'label' => pickListVal.getLabel(),
			'value' => pickListVal.getValue()
			});
		}

		return options;
	}

	public class ParentPDTO {
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public Decimal unitPrice;
		@AuraEnabled
		public String oppProductId;
		@AuraEnabled
		public Boolean open;
		@AuraEnabled
		public List<String> availableSubTypes = new List<String>();
		@AuraEnabled
		public Map<String, List<ProductDTO>> products = new Map<String, List<ProductDTO>>{
		'New Sale' => new List<ProductDTO>(),
		'Upsell (New Paying Account)' => new List<ProductDTO>(),
		'Upsell (Existing Account)' => new List<ProductDTO>(),
		'Renewal' => new List<ProductDTO>()
		};

		public ParentPDTO(Product2 p, Map<String, Decimal> productToPrice, Map<String, OpportunityLineItem> productToOppProduct) {
			this.id = p.Id;
			this.name = p.Name;
			this.unitPrice = productToPrice.get(p.Id);
			this.oppProductId = productToOppProduct.containsKey(p.Id) ? productToOppProduct.get(p.Id).Id : null;
			this.open = this.oppProductId != null;

			if (p.New_Business__c) {
				this.availableSubTypes.add('New Sale');
			}
			if (p.Upsell_New_Paying_Account__c) {
				this.availableSubTypes.add('Upsell (New Paying Account)');
			}
			if (p.Upsell_Existing_Account__c) {
				this.availableSubTypes.add('Upsell (Existing Account)');
			}
			if (p.Renewal__c) {
				this.availableSubTypes.add('Renewal');
			}

			for (Product2 child : p.Child_Products__r) {
				ProductDTO c = new ProductDTO(child);
				c.setPrice(productToPrice.get(child.Id));
				c.setSelected(productToOppProduct.get(child.Id));

				if (child.New_Business__c) {
					this.products.get('New Sale').add(c);
				}
				if (child.Upsell_New_Paying_Account__c) {
					this.products.get('Upsell (New Paying Account)').add(c);
				}
				if (child.Upsell_Existing_Account__c) {
					this.products.get('Upsell (Existing Account)').add(c);
				}
				if (child.Renewal__c) {
					this.products.get('Renewal').add(c);
				}
			}
		}

		public List<String> extractAllProductIdsExceptForSubType(String subType) {
			List<String> productIds = new List<String>();
			List<String> subTypes = new List<String>{'New Sale', 'Upsell (New Paying Account)', 'Upsell (Existing Account)', 'Renewal'};
			subTypes.remove(subTypes.indexOf(subType));
			List<String> selectedProductIds = extractSelectedProductIds(subType);

			for (String s : subTypes) {
				for (ProductDTO p : this.products.get(s)) {
					if (!selectedProductIds.contains(p.id)) {
						productIds.add(p.id);
					}
				}
			}

			return productIds;
		}

		public List<String> extractSelectedProductIds(String subType) {
			List<String> selectedProductIds = new List<String>();

			for (ProductDTO p : this.products.get(subType)) {
				if (p.selected) {
					selectedProductIds.add(p.id);
				}
			}

			return selectedProductIds;
		}
	}

	public static void updateProductTracking(List<String> oppIds) {
		List<Opportunity> opps = [
				SELECT Id, Opportunity_Product_Tracking__c, Country_Filter__c, (
						SELECT Id, Product2.Name, Product2.ProductType__c, Product2.Parent_Product__r.Name, Product2.AddOnType__c
						FROM OpportunityLineItems
						WHERE Product_Tracking__c = true AND Product2.ProductType__c = 'SKU')
				FROM Opportunity
				WHERE Id IN: oppIds
		];

		for (Opportunity opp : opps) {
			Map<String, List<String>> solutionToSKUs = new Map<String, List<String>>();

			for (OpportunityLineItem op : opp.OpportunityLineItems) {
				String solution = op.Product2.Parent_Product__r.Name,
					   skuName = op.Product2.Name + (
								   op.Product2.AddOnType__c == 'Country' && String.isNotBlank(opp.Country_Filter__c) ?
								   ' (' + opp.Country_Filter__c + ')' :
								   ''
					   );

				if (solutionToSKUs.containsKey(solution)) {
					solutionToSKUs.get(solution).add(skuName);
				} else {
					solutionToSKUs.put(solution, new List<String>{skuName});
				}
			}

			opp.Opportunity_Product_Tracking__c = generateProductTrackingDescription(solutionToSKUs);
		}

		update opps;
	}

	private static String generateProductTrackingDescription(Map<String, List<String>> solutionToSKUs) {
		String details = '';

		for (String solution : solutionToSKUs.keySet()) {
			String skuDetails = '';

			for (String sku : solutionToSKUs.get(solution)) {
				skuDetails += '  • ' + sku + '\n';
			}

			details += solution + '\n' + skuDetails;
		}

		return details;
	}

	public class ProductDTO {
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String family;
		@AuraEnabled
		public Decimal unitPrice;
		@AuraEnabled
		public Boolean active;
		@AuraEnabled
		public Boolean selected;
		@AuraEnabled
		public Boolean initSelected;
		@AuraEnabled
		public Boolean disabled;
		@AuraEnabled
		public String oppProductId;
		@AuraEnabled
		public String purchaseMotion;
		@AuraEnabled
		public List<Map<String, String>> purchaseMotionOptions = new List<Map<String, String>>();

		public ProductDTO(Product2 p) {
			this.id = p.Id;
			this.name = p.Name;
			this.family = p.Family;
			this.active = p.IsActive;

			if (String.isNotBlank(p.Purchase_Motion_Options__c)) {
				for (String option : p.Purchase_Motion_Options__c.split(';')) {
					this.purchaseMotionOptions.add(new Map<String, String>{'label' => option, 'value' => option});
				}
			}
		}

		public void setPrice(Decimal unitPrice) {
			this.unitPrice = unitPrice;
		}

		public void setSelected(OpportunityLineItem oppProduct) {
			this.selected = oppProduct != null;
			this.initSelected = oppProduct != null;
			this.oppProductId = oppProduct != null ? oppProduct.Id : null;
			this.disabled = !this.active && !this.selected;
			this.purchaseMotion = oppProduct != null ? oppProduct.Purchase_Motion__c : (
					this.purchaseMotionOptions.size() == 1 ?
					this.purchaseMotionOptions.get(0).get('value') :
					null
			);
		}
	}
}