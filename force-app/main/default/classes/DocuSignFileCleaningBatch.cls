public class DocuSignFileCleaningBatch implements Database.Batchable<sObject>, Schedulable {
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new DocuSignFileCleaningBatch(), 1000);

    String tmp = 'DocuSignFileCleaningBatch';
    List<CronJobDetail> croneJobList = [
      SELECT Id
      FROM CronJobDetail
      WHERE Name = :tmp
    ];
    if (!croneJobList.isEmpty()) {
      List<CronTrigger> croneTriggerList = [
        SELECT Id
        FROM CronTrigger
        WHERE CronJobDetailId = :croneJobList.get(0).id
      ];
      if (!croneTriggerList.isEmpty()) {
        System.abortJob(croneTriggerList.get(0).id);
      }
    }

    Datetime workTime = System.now().addHours(1);
    String CRONEXP = getCronFromDateTime(workTime);
    System.debug('CRONEXP ' + CRONEXP);
    System.schedule(tmp, CRONEXP, new DocuSignFileCleaningBatch());
  }

  private String integrationUserId;
  private List<String> allowedSenderList = new List<String>{
    'joanna.abbou@similarweb.com',
    'beckaa@similarweb.com',
    'aryeh.abramowitz@similarweb.com',
    'mohamed.ali@similarweb.com',
    'rossanna.allenza@similarweb.com',
    'richard.alvarez@similarweb.com',
    'olga.barlavi@similarweb.com',
    'amy.barber@similarweb.com',
    'marco.benatoff@similarweb.com',
    'eitan.berger@similarweb.com',
    'sheraz.bhatti@similarweb.com',
    'yonni.bitan@similarweb.com',
    'bryan.bitton@similarweb.com',
    'anna.boykis@similarweb.com',
    'yasmine.brewer@similarweb.com',
    'diane.bucciero@similarweb.com',
    'veronika.bukhman@similarweb.com',
    'austin.cm@similarweb.com',
    'maxime.carenton@similarweb.com',
    'loren.rispoli@similarweb.com',
    'alexandre.chamla@similarweb.com',
    'hannah.charbit@similarweb.com',
    'pascalc@similarweb.com',
    'aaron.coury@similarweb.com',
    'john.curaba@similarweb.com',
    'karin.cygler@similarweb.com',
    'fabiana.daddario@similarweb.com',
    'anat.dabah@similarweb.com',
    'michal.dahan@similarweb.com',
    'elliott.davies@similarweb.com',
    'darren.davis@similarweb.com',
    'kyle.debenedittis@similarweb.com',
    'claire.decobecq@similarweb.com',
    'carol.decoene@similarweb.com',
    'liord@similarweb.com',
    'yael.degani@similarweb.com',
    'michael.dellamura@similarweb.com',
    'jamie.dellavalle@similarweb.com',
    'jeremie.delpit@similarweb.com',
    'victoria.dierickx@similarweb.com',
    'jeff.ding@similarweb.com',
    'donna@similarweb.com',
    'stefanie.eickriede@similarweb.com',
    'christopher.elrod@similarweb.com',
    'mio.endo@similarweb.com',
    'nina.faigenbaum@similarweb.com',
    'darren.farbstein@similarweb.com',
    'shani.feldman@similarweb.com',
    'paul.ferri@similarweb.com',
    'nataly.fisch@similarweb.com',
    'chris.foale@similarweb.com',
    'abi.foldes@similarweb.com',
    'aaron.friedman@similarweb.com',
    'lior.friedman@similarweb.com',
    'gregory.fryns@similarweb.com',
    'hadas.funt@similarweb.com',
    'theo.gaston-dreyfus@similarweb.com',
    'amy.gaunt@similarweb.com',
    'antoine.gay@similarweb.com',
    'josh.gellerman@similarweb.com',
    'lee.goldenberg@similarweb.com',
    'nathan.goldstein@similarweb.com',
    'diana.golovko@similarweb.com',
    'debra.gordon@similarweb.com',
    'nitzan@similarweb.com',
    'anne.groisman@similarweb.com',
    'maayan.krush@similarweb.com',
    'florine.guitard@similarweb.com',
    'michael.hagan@similarweb.com',
    'kimberley.haley@similarweb.com',
    'kaoru.hara@similarweb.com',
    'gilles.haumont@similarweb.com',
    'brian.hayes@similarweb.com',
    'pedro.herrera@similarweb.com',
    'emmanuel@similarweb.com',
    'sita.huber@similarweb.com',
    'yoshimaru.imano@similarweb.com',
    'jay.imus@similarweb.com',
    'alexandra.izrailevich@similarweb.com',
    'sacha.jabes@similarweb.com',
    'alex.jones@similarweb.com',
    'john.jurjevic@similarweb.com',
    'dan.kadec@similarweb.com',
    'hadar.kedem@similarweb.com',
    'lotem.kaiser@similarweb.com',
    'ilana.keylis@similarweb.com',
    'takako.kiyoshige@similarweb.com',
    'shiran.koren@similarweb.com',
    'eli.kovler@similarweb.com',
    'ilana.kreinin@similarweb.com',
    'caroline.lee@similarweb.com',
    'liyen.lee@similarweb.com',
    'gabriella.lehrer@similarweb.com',
    'aaron.lesser@similarweb.com',
    'jonathan.lev@similarweb.com',
    'omri.levy@similarweb.com',
    'matthew.lipkind@similarweb.com',
    'smadar.ludomirski@similarweb.com',
    'joris.mabrouk@similarweb.com',
    'andrei.maretski@similarweb.com',
    'yishai.markovitz@similarweb.com',
    'tim.marshall@similarweb.com',
    'anna.mazziotti@similarweb.com',
    'eric.mccafferty@similarweb.com',
    'turlough.mcgivney@similarweb.com',
    'john.mclaren@similarweb.com',
    'aaron.meekins@similarweb.com',
    'jack.melvin@similarweb.com',
    'ron.mendelson@similarweb.com',
    'shuki.merlis@similarweb.com',
    'johanna.messas@similarweb.com',
    'sean.mizrahi@similarweb.com',
    'sara.moses@similarweb.com',
    'christopher.munekawa@similarweb.com',
    'antonello.musina@similarweb.com',
    'kazuhiro.nagao@similarweb.com',
    'alex.nisenzon@similarweb.com',
    'samantha.novick@similarweb.com',
    'derek.paine@similarweb.com',
    'pavlo.panayiotou@similarweb.com',
    'karina.paramonov@similarweb.com',
    'mayanp@similarweb.com',
    'amandap@similarweb.com',
    'maria.pashi@similarweb.com',
    'christian.penfold@similarweb.com',
    'lawrence.penfold@similarweb.com',
    'marcanthony.petrecca@similarweb.com',
    'chelsea.pincus@similarweb.com',
    'evgeniya.prihodko@similarweb.com',
    'jamesp@similarweb.com',
    'nikki.radu@similarweb.com',
    'maria.rakhcheva@similarweb.com',
    'leah.rapaport@similarweb.com',
    'sam.rentz@similarweb.com',
    'joe.resnick@similarweb.com',
    'rachel.rix@similarweb.com',
    'emilie.rochedy@similarweb.com',
    'scott.rogers-jones@similarweb.com',
    'sherisse.rogers@similarweb.com',
    'kirsty.roos@similarweb.com',
    'tom.ross@similarweb.com',
    'stephane.sabadell@similarweb.com',
    'shinichi.sato@similarweb.com',
    'kerry.saxena@similarweb.com',
    'hannah.schulze@similarweb.com',
    'robin.schwartz@similarweb.com',
    'john.scott@similarweb.com',
    'natalie.serrano@similarweb.com',
    'mathilde.seven@similarweb.com',
    'harriet.shakked@similarweb.com',
    'marissa.shapiro@similarweb.com',
    'rachelle.shapiro@similarweb.com',
    'manuela.shimberg@similarweb.com',
    'liudmyla.shyk@similarweb.com',
    'omri.silberman@similarweb.com',
    'sams@similarweb.com',
    'irena.simakova@similarweb.com',
    'alexas@similarweb.com',
    'uris@similarweb.com',
    'galia.sopher@similarweb.com',
    'lola.stolper@similarweb.com',
    'eric.suen@similarweb.com',
    'ryans@similarweb.com',
    'brian.sweeter@similarweb.com',
    'marycatherine.taglang@similarweb.com',
    'ryo.taira@similarweb.com',
    'akira.tanaka@similarweb.com',
    'senzo.tanaka@similarweb.com',
    'rinat.teshuva@similarweb.com',
    'jonathant@similarweb.com',
    'scott.trabucco@similarweb.com',
    'nickt@similarweb.com',
    'kyle.tuppa@similarweb.com',
    'limor.tzach@similarweb.com',
    'david.upton@similarweb.com',
    'chantelle.vdm@similarweb.com',
    'celine.vanschoote@similarweb.com',
    'yael.versano@similarweb.com',
    'jamie.wang@similarweb.com',
    'owen.west@similarweb.com',
    'shoney.yakubjanov@similarweb.com',
    'noa.yang@similarweb.com',
    'roy.yarkoni@similarweb.com',
    'keiko.zeltzer@similarweb.com',
    'ji.zhou@similarweb.com',
    'david.zimmerman@similarweb.com',
    'rajat.gaur@similarweb.com',
    'adis@similarweb.com',
    'colin.jenke@similarweb.com',
    'shaan.martin@similarweb.com',
    'chris.martini@similarweb.com',
    'fallon.lior@similarweb.com',
    'owen.west@similarweb.com',
    'galia.sopher@similarweb.com',
    'alyssa.anzur@similarweb.com',
    'anat.avshalom@similarweb.com',
    'nadav.rosen@similarweb.com',
    'alexa.messinger@similarweb.com',
    'anne.groisman@similarweb.com',
    'avi.guedj@similarweb.com',
    'daniel.sonnenschein@similarweb.com',
    'kyohei.morita@similarweb.com',
    'sherisse.rogers@similarweb.com',
    'gilad.oren@similarweb.com',
    'deborahr@similarweb.com',
    'jaredf@similarweb.com',
    'mackenzie.white@similarweb.com',
    'guy.slonim@similarweb.com',
    'roy.glueckstern@similarweb.com',
    'yamaya@gaprise.com',
    'y.yamamoto@gaprise.com',
    'shelly.yehuda@similarweb.com',
    'miyazono-0240@gaprise.com',
    'shogo.suzuki@similarweb.com',
    'haley.belcher@similarweb.com',
    'kuroda-0216@gaprise.com',
    'davidg@similarweb.com',
    'kaieda@gaprise.com',
    'vladimir.coltuc@similarweb.com',
    'merav.david@similarweb.com',
    'huang@gaprise.com',
    'evgeny.yanovskiy@similarweb.com',
    'arielle.felsen@similarweb.com',
    'ana.guedes@similarweb.com',
    'alissa.dangelo@similarweb.com',
    'troy.aral@similarweb.com',
    'martin.descourtieux@similarweb.com',
    'adam.lerner@similarweb.com',
    'nishta.singh@similarweb.com.community',
    'nelly.bacovic@similarweb.com',
    'keiko.zeltzer@similarweb.com',
    'pedro.garcia@similarweb.com',
    'saleh.elkadre@similarweb.com',
    'mukund.mishra@similarweb.com',
    'rafael.consoni@similarweb.com',
    'jacqueline.glat@similarweb.com',
    'isabela.fraga@similarweb.com',
    'jason.pee@similarweb.com',
    'rahul.khosla@similarweb.com',
    'nishta.singh@similarweb.com',
    'kawasaki-0243.similarweb@gaprise.com',
    'matt.hodgson@similarweb.com.community',
    'matt.hodgson@similarweb.com',
    'juliana.junkes@similarweb.com',
    'scott.rogers-jones@similarweb.com',
    'harasawa+1@gaprise.com',
    'tabata+1@gaprise.com',
    'okubo-0294+1@gaprise.com',
    'senzo.tanaka@similarweb.com',
    'jun.chew@similarweb.com',
    'stefania.balsamo@similarweb.com',
    'meiriane.jacobsen@similarweb.com',
    'roxanne.vickerman@similarweb.com',
    'fabiano.finger@similarweb.com',
    'suetee.gan@similarweb.com',
    'francesca.ermidoro@similarweb.com',
    'tiziana.pugliese@similarweb.com',
    'nathan.parker@similarweb.com',
    'akira.tanaka@similarweb.com',
    'ryo.taira@similarweb.com',
    'kaoru.hara@similarweb.com',
    'francesca.capacchione@similarweb.com',
    'annie.soh@similarweb.com',
    'kazuhiro.nagao@similarweb.com',
    'harshit.kalra@similarweb.com',
    'carroll.kee@similarweb.com',
    'nakahara-02901@gaprise.com',
    'shimizu-0202+1@gaprise.com',
    'arbaz.uddin@similarweb.com',
    'miki-0217+1@gaprise.com',
    'adrian.burrell@similarweb.com',
    'shinichi.sato@similarweb.com',
    'aiko-0296+1@gaprise.com',
    'sugiyama@gaprise.com',
    'okuhara+1@gaprise.com',
    'amar.duggal@similarweb.com',
    'amar.duggal@similarweb.com.community',
    'brazil@similarweb.com',
    'bekir.gogce@similarweb.com',
    'vivek.sharma@similarweb.com',
    'oikawa-0283+1@gaprise.com',
    'tsuneishi-0226+1@gaprise.com',
    'wakana.kawamura@gaprise.com',
    'carroll.kee@similarweb.com.community',
    'soichi.kisa@gaprise.com',
    'ota-0230.similarweb@gaprise.com',
    'yoshimaru.imano@similarweb.com',
    'stefania.balsamo@similarweb.com.community',
    'juliana.junkes@similarweb.com.community',
    'francesca.ermidoro@similarweb.com.community',
    'adrian.burrell@similarweb.com.community',
    'kori-03001@gaprise.com',
    'similarweb.contact@gaprise.com',
    'sumedha@similarweb.com',
    'fabiano.finger@similarweb.com.community',
    'harshit.kalra@similarweb.com.community',
    'nelly.bacovic@similarweb.com.community',
    'rafael.consoni@similarweb.com.community',
    'jun.chew@similarweb.com.community',
    'annie.soh@similarweb.com.community',
    'jason.pee@similarweb.com.community',
    'suetee.gan@similarweb.com.community',
    'jacqueline.glat@similarweb.com.community',
    'isabela.fraga@similarweb.com.community',
    'arbaz.uddin@similarweb.com.community',
    'francesca.capacchione@similarweb.com.community',
    'urgel.augustin@similarweb.com',
    'shadab.alam@similarweb.com.community',
    'david.warmuz@similarweb.com.community',
    'himanshu.gaba@similarweb.com.community',
    'amit.thapliyal@similarweb.com.community',
    'pedro.garcia@similarweb.com.community',
    'meiriane.jacobsen@similarweb.com.community',
    'rahul.kosla@similarweb.com',
    'rajat.gaur@similarweb.com',
    'chris.martini@similarweb.com',
    'kyohei.morita@similarweb.com',
    'yamaya+1@gaprise.com',
    'y.yamamoto+1@gaprise.com',
    'miyazono-0240.similarweb@gaprise.com',
    'shogo.suzuki@similarweb.com',
    'natsuko.kuroda@gaprise.com',
    'kaieda@similargroup.com',
    'huang+1@gaprise.com',
    'ana.guedes@similarweb.com'
  };

  public DocuSignFileCleaningBatch() {
    integrationUserId = '0050O000007iQXwQAM';
  }

  public DocuSignFileCleaningBatch(String userId) {
    integrationUserId = userId;
  }

  public Iterable<sObject> start(Database.BatchableContext BC) {
    return [
      SELECT Id, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :integrationUserId
    ];
  }

  public void execute(
    Database.BatchableContext BC,
    List<ContentDocumentLink> scope
  ) {
    Set<Id> cdIds = new Set<Id>();
    Map<Id, List<ContentDocument>> dsStatusIdToFile = new Map<Id, List<ContentDocument>>();
    List<ContentDocument> cdToDelete = new List<ContentDocument>();
    for (ContentDocumentLink sObj_i : scope) {
      cdIds.add(sObj_i.ContentDocumentId);
    }
    List<ContentDocumentLink> cdList = [
      SELECT Id, ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE ContentDocumentId IN :cdIds AND LinkedEntityId != :integrationUserId
    ];
    for (ContentDocumentLink cdl_i : cdList) {
      System.debug('tt ' + cdl_i.LinkedEntityId);
      if (((String) cdl_i.LinkedEntityId).startsWith('a68')) {
        List<ContentDocument> cdListForMap = new List<ContentDocument>();
        if (dsStatusIdToFile.containsKey(cdl_i.LinkedEntityId)) {
          cdListForMap = dsStatusIdToFile.get(cdl_i.LinkedEntityId);
        }
        cdListForMap.add(new ContentDocument(Id = cdl_i.ContentDocumentId));

        dsStatusIdToFile.put(cdl_i.LinkedEntityId, cdListForMap);
      }
    }

    List<dsfs__DocuSign_Status__c> dsStatusList = [
      SELECT Id, dsfs__Sender_Email__c
      FROM dsfs__DocuSign_Status__c
      WHERE Id IN :dsStatusIdToFile.keySet()
    ];
    for (dsfs__DocuSign_Status__c dsStatus_i : dsStatusList) {
      if (
        !allowedSenderList.contains(
          dsStatus_i.dsfs__Sender_Email__c.toLowerCase()
        )
      ) {
        cdToDelete.addAll(dsStatusIdToFile.get(dsStatus_i.Id));
      }
    }
    delete cdToDelete;
  }

  public void finish(Database.BatchableContext BC) {
  }

  public static String getCronFromDateTime(Datetime executeTime) {
    return executeTime.second() +
      ' ' +
      executeTime.minute() +
      ' ' +
      executeTime.hour() +
      ' ' +
      executeTime.day() +
      ' ' +
      executeTime.month() +
      ' ? ' +
      executeTime.year();
  }
}
