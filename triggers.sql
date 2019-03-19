CREATE TRIGGER ConferenceDayCheckDate
  -- done
  ON Conference_Days
  AFTER INSERT, UPDATE
AS
  BEGIN
    IF EXISTS(
        SELECT *
        FROM inserted as i
               INNER JOIN Conferences as c on i.ConferenceID = c.ConferenceID
        WHERE i.Date < c.BeginDate
           or i.Date > c.EndDate
    )
      BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'This day is not in conference beginDate and endDate', 1;
      end
  end
GO

drop trigger WorkshopDayCheckTime

CREATE TRIGGER WorkshopDayCheckTime
  -- done
  ON Workshop_Days
  AFTER INSERT, UPDATE
AS
  BEGIN
    --     IF EXISTS(
    --         SELECT *
    --         FROM inserted as i
    --                cross join Workshop_Days as w
    --         where w.WorkshopDayID <> i.WorkshopDayID
    --           and i.conferenceDayID = w.conferenceDayID
    --           and (i.startTime <= w.StartTime and i.endTime >= w.endTime)
    --     )
    --       BEGIN
    --         ROLLBACK TRANSACTION;
    --         THROW 50001, 'two workshop overlap date', 1;
    --       end
    IF EXISTS(
        SELECT *
        FROM inserted as i
        where dbo.GetLimitConference(dbo.getConferenceID(i.ConferenceDayID)) < i.limit
    )
      BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Too small places limit Conference', 1;
      end
  end
GO


CREATE TRIGGER CheckPriceLevel
  ON Prices
  -- done
  AFTER INSERT, UPDATE
AS
  BEGIN
    IF EXISTS(
        SELECT *
        FROM inserted as i
               INNER JOIN Conferences as c on i.ConferenceID = c.ConferenceID
        WHERE i.StartDate >= c.beginDate
    )
      BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, 'price thresholds can not end before the conference begins', 1;
      end

    IF EXISTS(
        SELECT *
        FROM inserted as i
               cross join prices as p
        where p.conferenceId = i.conferenceID
          and (i.startDate <= p.endDate and i.endDate >= p.startDate)
          and p.priceID <> i.priceID
    )
      BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, 'two prices overlap date', 1;
      end
  end
GO

drop trigger TooFewPlacesInTheConference

CREATE TRIGGER TooFewPlacesInTheConference
  -- done
  ON Order_Days
  AFTER INSERT, UPDATE
AS
  BEGIN
    IF EXISTS(
        SELECT *
        FROM inserted as i
        WHERE (ISNULL(dbo.GetFreePlacesConferenceDay(i.conferenceDayID), 0) - i.normalTickets - i.studentTickets) < 0
    )
      BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Too few places in the conference', 1;
      end
  end
GO

SELECT [so].[name]                                         AS [trigger_name],
       USER_NAME([so].[uid])                               AS [trigger_owner],
       USER_NAME([so2].[uid])                              AS [table_schema],
       OBJECT_NAME([so].[parent_obj])                      AS [table_name],
       OBJECTPROPERTY([so].[id], 'ExecIsUpdateTrigger')    AS [isupdate],
       OBJECTPROPERTY([so].[id], 'ExecIsDeleteTrigger')    AS [isdelete],
       OBJECTPROPERTY([so].[id], 'ExecIsInsertTrigger')    AS [isinsert],
       OBJECTPROPERTY([so].[id], 'ExecIsAfterTrigger')     AS [isafter],
       OBJECTPROPERTY([so].[id], 'ExecIsInsteadOfTrigger') AS [isinsteadof],
       OBJECTPROPERTY([so].[id], 'ExecIsTriggerDisabled')  AS [disabled]
FROM sysobjects AS [so]
       INNER JOIN sysobjects AS so2 ON so.parent_obj = so2.Id
WHERE [so].[type] = 'TR'


CREATE TRIGGER CheckBookedPlacesInTheConferenceDay
  -- done
  ON Participants
  AFTER INSERT, UPDATE
AS
  BEGIN
    DECLARE @declaredParticipant int
    SET @declaredParticipant = (select od.NormalTickets + od.StudentTickets
                                from inserted as i
                                       inner join Order_Days as od on od.OrderDayID = i.OrderDayID)

    DECLARE @reservedParticipant int
    SET @reservedParticipant = (SELECT count(*)
                                from inserted as i
                                       cross join participants as p
                                where p.OrderDayID = i.OrderDayID
                                  and i.ParticipantID <> p.ParticipantID)

    BEGIN
      IF (@declaredParticipant <= @reservedParticipant)
        BEGIN
          ROLLBACK TRANSACTION;
          THROW 50001, 'Over Booked Places In The Conference Day', 1;
        end
    end

  END


CREATE TRIGGER CheckOverlappingWorkshopsForParticipant -- done
  ON Workshop_Participants
  AFTER INSERT, UPDATE
AS
  BEGIN
    DECLARE @startTime time
    SET @startTime = (select wd.StartTime
                      from inserted as i
                             inner join Workshop_Days as wd on wd.WorkshopDayID = i.WorkshopDayID)

    DECLARE @endTime time
    SET @endTime = (select wd.EndTime from inserted as i
                                             inner join Workshop_Days as wd on wd.WorkshopDayID = i.WorkshopDayID)

    DECLARE @participantID int
    SET @participantID = (select i.participantID from inserted as i)

    DECLARE @WorkshopDayID int
    SET @WorkshopDayID = (select i.WorkshopDayID from inserted as i)

    IF EXISTS(
        SELECT *
        FROM Workshop_Participants as wp
               inner join Workshop_Days as wd on wd.WorkshopDayID = wp.WorkshopDayID
        WHERE wp.participantID = @participantID
          and wd.WorkshopDayID <> @WorkshopDayID
          and (wd.startTime <= @endTime and wd.EndTime >= @startTime)
    )
      BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Overlap Workshops for participantID', 1;
      end

  END


CREATE TRIGGER CheckLimitWorkshopDayAndConferenceDay -- done
  ON Workshop_Days
  AFTER INSERT, UPDATE
AS
  BEGIN
    IF EXISTS(
        SELECT *
        FROM inserted as i
               inner join Conference_Days as cd on cd.ConferenceDayID = i.ConferenceDayID
               inner join Conferences as c on c.conferenceID = cd.conferenceID
        WHERE ISNULL(c.Limit, 0) < ISNULL(i.Limit, 0)
    )
      BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Too much limit in the workshop', 1;
      end
  end
GO


CREATE TRIGGER TooFewPlacesInWorkshop
  ON Workshop_Orders
  AFTER INSERT, UPDATE
AS
  BEGIN
    IF EXISTS(
        SELECT *
        FROM inserted as i
        WHERE (ISNULL(dbo.GetFreePlacesWorkshopDay(i.workshopDayID), 0) - i.normalTickets - i.studentTickets) < 0
    )
      BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Too few places in the workshop', 1;
      end
  end
GO