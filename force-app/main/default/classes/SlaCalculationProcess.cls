/**
 * Created by Alon.Shalev on 11/17/2024.
 */

public with sharing class SlaCalculationProcess {

    public static Datetime getCalculatedSlaDateTime(Datetime currentDateTime, String userTimeZone) {
        Datetime calculatedSlaDateTime = currentDateTime;
        TimeZone tz = TimeZone.getTimeZone(userTimeZone);
        System.debug(tz);
        System.debug(tz.getOffset(currentDateTime) / 3600000);
        Integer offsetHours = tz.getOffset(currentDateTime) / 3600000;
        Time endOfWorkDay = Time.newInstance(18 + (-1 * offsetHours), 0, 0, 0);
        Time startOfWorkDay = Time.newInstance(9 + (-1 * offsetHours), 0, 0, 0);
        Datetime startDayOfWorkDatetime = Datetime.newInstanceGmt(currentDateTime.date(), startOfWorkDay);
        Datetime endDayOfWorkDatetime = Datetime.newInstanceGmt(currentDateTime.date(), endOfWorkDay);
        String whereUStand = currentDateTime > endDayOfWorkDatetime ? 'AfterWorkDay' : currentDateTime < startDayOfWorkDatetime ? 'BeforeWorkDay' : 'Inside';
        switch on whereUStand {
            when 'AfterWorkDay' {
                calculatedSlaDateTime = Datetime.newInstanceGmt(currentDateTime.addDays(1).date(), startOfWorkDay);

            }
            when 'BeforeWorkDay' {
                calculatedSlaDateTime = Datetime.newInstanceGmt(currentDateTime.date(), startOfWorkDay);
            }
//            when 'Inside'{
//
//            }
        }
        String dayOfWeek = calculatedSlaDateTime.format('EEEE');
        switch on dayOfWeek {
            when 'Saturday' {
                calculatedSlaDateTime = calculatedSlaDateTime.addDays(2); // Datetime.newInstanceGmt(calculatedSlaDateTime.date().addDays(2), Time.newInstance(9+(-1*offsetHours),0,0,0));
            }
            when 'Sunday' {
                calculatedSlaDateTime = calculatedSlaDateTime.addDays(1); //Datetime.newInstanceGmt(calculatedSlaDateTime.date().addDays(1), Time.newInstance(9+(-1*offsetHours),0,0,0));

            }
        }
        return calculatedSlaDateTime;
    }

}