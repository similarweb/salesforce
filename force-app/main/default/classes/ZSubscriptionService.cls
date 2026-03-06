public class ZSubscriptionService {

    public List<Account> updateRelatedAccounts(Set<Id> accountIds){
        Map<Id, List<Zuora__Subscription__c>> accountToSubscriptions = this.collectRelatedSubscriptions(accountIds);
        Map<Id, List<zqu__Quote__c>> accountToQuotes = this.collectRelatedQuotes(accountIds);

        List<Account> updatedAccounts = new List<Account>();
        for(Id accId : accountIds){
            List<zqu__Quote__c> relatedQuotes = accountToQuotes.get(accId);
            List<Zuora__Subscription__c> relatedSubscriptions = accountToSubscriptions.get(accId);

            Boolean hasQuotes = relatedQuotes != null && !relatedQuotes.isEmpty();
            Boolean hasSubscriptions = relatedSubscriptions != null && !relatedSubscriptions.isEmpty();

            if(hasQuotes && hasSubscriptions){
                Account updateAccount = this.generateUpdatedAccount(accId, relatedQuotes, relatedSubscriptions);
                updatedAccounts.add(updateAccount);
            } else if(hasQuotes){
                Account updateAccount = this.generateUpdatedAccountByQuotes(accId, relatedQuotes);
                updatedAccounts.add(updateAccount);
            } else if(hasSubscriptions){
                Account updateAccount = this.generateUpdatedAccount(accId, relatedSubscriptions);
                updatedAccounts.add(updateAccount);
            }
        }
        
        return updatedAccounts;
    }

    private Map<Id, List<Zuora__Subscription__c>> collectRelatedSubscriptions(Set<Id> accountIds){
        List<Zuora__Subscription__c> accountSubscriptions = [
            SELECT 
                Id,
                Zuora__Account__c,
                Zuora__NextRenewalDate__c,
                CreatedDate
            FROM Zuora__Subscription__c 
            WHERE Zuora__Account__c IN :accountIds AND Zuora__NextRenewalDate__c != null
        ];
        Map<Id, List<Zuora__Subscription__c>> accountToSubscriptions = new Map<Id, List<Zuora__Subscription__c>>();
        for(Zuora__Subscription__c sub : accountSubscriptions){
            Id accountId = sub.Zuora__Account__c;
            if(accountToSubscriptions.containsKey(accountId) == false){
                accountToSubscriptions.put(accountId, new List<Zuora__Subscription__c>());
            }
            accountToSubscriptions.get(accountId).add(sub);
        }
        return accountToSubscriptions;
    }

    private Map<Id, List<zqu__Quote__c>> collectRelatedQuotes(Set<Id> accountIds){
        List<zqu__Quote__c> accountQuotes = [
            SELECT 
                zqu__Account__c, 
                zqu__SubscriptionTermEndDate__c
            FROM zqu__Quote__c
            WHERE
                    zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)'
                AND zqu_Quote_Status__c = 'Quote Pending Renewal Date' 
                AND zqu__Account__c IN :accountIds
        ];
        Map<Id, List<zqu__Quote__c>> accountToQuotes = new Map<Id, List<zqu__Quote__c>>();
        if(accountQuotes.size() > 0){
            for(zqu__Quote__c quote : accountQuotes){
                Id accountId = quote.zqu__Account__c;
                if(accountToQuotes.containsKey(accountId) == false){
                    accountToQuotes.put(accountId, new List<zqu__Quote__c>());
                }
                accountToQuotes.get(accountId).add(quote);
            }
        }
        return accountToQuotes;
    }

    private Account generateUpdatedAccount(Id accountId, List<zqu__Quote__c> relatedQuotes, List<Zuora__Subscription__c> relatedSubscriptions){
        Date quoteNextRenewalDate = this.getQuoteNextRenewalDate(relatedQuotes);
        Date subscriptionNextRenewalDate = this.getSubscriptionNextRenewalDate(relatedSubscriptions);
        Date nextRenewalDate = this.selectNextRenewalDate(quoteNextRenewalDate, subscriptionNextRenewalDate);

        return new Account(
            Id = accountId,
            fr_NextRenewalDate__c = nextRenewalDate
        );
    }

    private Account generateUpdatedAccount(Id accountId, List<Zuora__Subscription__c> relatedSubscriptions){
        Date nextRenewalDate = this.getSubscriptionNextRenewalDate(relatedSubscriptions);
        
        return new Account(
            Id = accountId,
            fr_NextRenewalDate__c = nextRenewalDate
        );
    }

    private Account generateUpdatedAccountByQuotes(Id accountId, List<zqu__Quote__c> relatedQuotes){
        Date nextRenewalDate = this.getQuoteNextRenewalDate(relatedQuotes);

        return new Account(
            Id = accountId,
            fr_NextRenewalDate__c = nextRenewalDate
        );
    }

    private Date getQuoteNextRenewalDate(List<zqu__Quote__c> relatedQuotes){
        Date subscriptionTermEndDate = relatedQuotes[0].zqu__SubscriptionTermEndDate__c;
        for(zqu__Quote__c quote : relatedQuotes){
            Date quoteSubscriptionTermEndDate = quote.zqu__SubscriptionTermEndDate__c;
            if(subscriptionTermEndDate < quoteSubscriptionTermEndDate){
                subscriptionTermEndDate = quoteSubscriptionTermEndDate;
            }
        }
        return subscriptionTermEndDate;
    }

    private Date getSubscriptionNextRenewalDate(List<Zuora__Subscription__c> relatedSubscriptions){
        Date nextRenewalDate = relatedSubscriptions[0].Zuora__NextRenewalDate__c;
        for(Zuora__Subscription__c sub : relatedSubscriptions){
            Date subNextRenewalDate = sub.Zuora__NextRenewalDate__c;
            if(nextRenewalDate < subNextRenewalDate){
                nextRenewalDate = subNextRenewalDate;
            }
        }
        return nextRenewalDate;
    }

    private Date selectNextRenewalDate(Date quoteNextRenewalDate, Date subscriptionNextRenewalDate){
        if(quoteNextRenewalDate > subscriptionNextRenewalDate){
            return quoteNextRenewalDate;
        } else {
            return subscriptionNextRenewalDate;
        }
    }
}