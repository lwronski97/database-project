CREATE FUNCTION [getCountryID] -- done
  (
    @countryName varchar(255)
  )
  RETURNS int
AS
  BEGIN
    RETURN (Select CountryID From Countries Where CountryName = @CountryName)
  END
GO

CREATE FUNCTION [getCityID] -- done
  (
    @countryID varchar(255),
    @cityName  varchar(255)
  )
  RETURNS int
AS
  BEGIN
    RETURN (Select cityID From Cities Where CountryID = @countryID
                                        and cityName = @cityName)
  END
GO

CREATE FUNCTION [getConferenceDayID] -- done
  (
    @conferenceID int,
    @date         date
  )
  RETURNS int
AS
  BEGIN
    RETURN (Select ConferenceDayID From [Conference_Days] WHERE ConferenceID = @conferenceID
                                                            AND date = @date)

  END
GO

CREATE FUNCTION [getConferenceID] -- done
  (
    @conferenceDayID int
  )
  RETURNS int
AS
  BEGIN
    RETURN (Select ConferenceID From Conference_Days WHERE conferenceDayID = @conferenceDayID)

  END
GO


CREATE FUNCTION [GetUsedPlacesConferenceDay] -- done / need test
  (
    @conferenceDayID int
  )
  RETURNS int
AS
  BEGIN
    RETURN ISNULL((SELECT SUM(NormalTickets) + SUM(ISNULL(StudentTickets, 0))
                   FROM [Order_Days]
                   Where ConferenceDayID = @conferenceDayID), 0)
  END
GO

CREATE FUNCTION [GetUsedPlacesWorkshopDay] -- done / need test
  (
    @workshopDayID int
  )
  RETURNS int
AS
  BEGIN
    RETURN ISNULL((SELECT SUM(NormalTickets) + SUM(ISNULL(StudentTickets, 0))
                   FROM [Workshop_Orders]
                   Where WorkshopDayID = @WorkshopDayID), 0)
  END
GO

CREATE FUNCTION [GetLimitConference] -- done
  (
    @conferenceID int
  )
  RETURNS int
AS
  BEGIN
    RETURN (SELECT Limit FROM Conferences WHERE ConferenceID = @conferenceID)
  END
GO


CREATE FUNCTION [GetLimitWorkshop] -- done
  (
    @workshopDayID int
  )
  RETURNS int
AS
  BEGIN
    RETURN (SELECT Limit FROM Workshop_Days WHERE workshopDayID = @workshopDayID)
  END
GO


CREATE FUNCTION [GetFreePlacesConferenceDay] -- done / need test
  (
    @conferenceDayID INT
  )
  RETURNS INT
AS
  BEGIN

    DECLARE @limit int = dbo.getLimitConference( dbo.getConferenceID( @conferenceDayID ) )

    DECLARE @occupied int = dbo.GetUsedPlacesConferenceDay(@conferenceDayID)

    RETURN @limit - @occupied
  END
GO


CREATE FUNCTION [GetFreePlacesWorkshopDay] -- done / need test
  (
    @workshopDayID INT
  )
  RETURNS INT
AS
  BEGIN

    DECLARE @limit int = dbo.GetLimitWorkshop(@workshopDayID)

    DECLARE @occupied int = dbo.GetUsedPlacesWorkshopDay(@workshopDayID)

    RETURN @limit - @occupied
  END
GO


CREATE FUNCTION [GetPriceDiscountConference]
  (
    @conferenceID int,
    @date         date
  )
  RETURNS float
AS
  BEGIN
    RETURN ISNULL((SELECT Discount FROM Prices WHERE ConferenceID = @conferenceID
                                                 AND @date BETWEEN StartDate and EndDate), 0)
  END
GO


drop function GetOrderNormalPriceTicket

CREATE FUNCTION [GetOrderNormalPriceTicket]
  (
    @orderID      INT,
    @orderPayment DATE
  )
  RETURNS MONEY
AS
  BEGIN
    RETURN ISNULL((SELECT distinct( c2.BasePrice * (1 - dbo.GetPriceDiscountConference(c2.ConferenceID, @orderPayment)) )
                   FROM [Order_Days] as od
                          JOIN Conference_Days as c ON c.ConferenceDayID = od.ConferenceDayID
                          JOIN Conferences as c2 ON c2.conferenceID = c.ConferenceID
                          JOIN Orders as o ON o.orderID = od.OrderID
                   WHERE o.orderID = @orderID), 0)
  END
GO


CREATE FUNCTION [GetNumberNormalConferenceDayParticipants]
  (
    @ConferenceDayID int
  )
  RETURNS int
AS
  BEGIN
    RETURN ISNULL((SELECT SUM(NormalTickets) FROM Order_Days WHERE @ConferenceDayID = ConferenceDayID), 0)
  END
GO

CREATE FUNCTION [GetNumberStudentConferenceDayParticipants]
  (
    @ConferenceDayID int
  )
  RETURNS int
AS
  BEGIN
    RETURN ISNULL((SELECT SUM(StudentTickets) FROM Order_Days WHERE @ConferenceDayID = ConferenceDayID), 0)
  END
GO

CREATE FUNCTION [GetConferenceDayParticipants]
  (
    @ConferenDayID int
  )
  RETURNS int
AS
  BEGIN
    RETURN (SELECT dbo.GetNumberNormalConferenceDayParticipants(@ConferenDayID) +
                   dbo.GetNumberStudentConferenceDayParticipants(@ConferenDayID))
  END
GO

CREATE FUNCTION [GetConferenceIDUsedConferenceDayID]
  (
    @ConferenceDayID int
  )
  RETURNS int
AS
  BEGIN
    RETURN (SELECT conferenceID from conference_Days where @ConferenceDayID = ConferenceDayID)
  END
GO


drop function GetPriceOrder

CREATE FUNCTION [GetPriceOrder]
  (
    @orderID int,
    @date    date
  )
  RETURNS float
AS
  BEGIN

    DECLARE @normalprice MONEY = dbo.GetOrderNormalPriceTicket(@orderID, @date)

    DECLARE @discount REAL = (SELECT distinct ( c2.StudentDiscount )
                              FROM [Order_Days] as od
                                     JOIN Conference_Days as c ON c.ConferenceDayID = od.ConferenceDayID
                                     JOIN Conferences as c2 ON c2.conferenceID = c.ConferenceID
                                     JOIN Orders as o ON o.orderID = od.OrderID
                              WHERE o.orderID = @orderID)


    DECLARE @reservationCost MONEY = (Select Sum(NormalTickets) * @normalprice +
                                             Sum(StudentTickets) * @normalprice * (1 - @discount)
                                      From [Order_Days] as od
                                      WHERE od.orderID = @orderID)

    DECLARE @workshopCost MONEY = (Select sum(cost)
                                   From (Select (Select SUM(wo.StudentTickets  * wd.Price) +
                                                        SUM(wo.NormalTickets * wd.Price)
                                                 FROM [Workshop_Orders] as wo
                                                        JOIN [Workshop_Days] as wd
                                                          ON wd.WorkshopDayID = wo.WorkshopDayID
                                                 WHERE wo.OrderDayID = od.OrderDayID) as cost
                                         From [Order_Days] as od
                                         WHERE od.orderID = @orderID)
                                            data)


    RETURN ISNULL(@workshopCost, 0) + ISNULL(@reservationCost, 0)
  END


CREATE FUNCTION [GetConferenceDaysList]
  (
    @ConferenceID int
  )
  RETURNS TABLE
AS
    RETURN (SELECT * from Conference_Days where @ConferenceID = ConferenceID)
GO

drop function GetWorkshopDayParticipantsList

CREATE FUNCTION [GetWorkshopDayParticipantsList]
  (
  @WorkshopDayID int
  )
  RETURNS TABLE
AS
  RETURN ( select persons.FirstName, persons.LastName, persons.Phone, persons.personID from Workshop_Participants as wp
           inner join participants as p on p.participantID = wp.participantID
           inner join persons  on persons.personID = p.personID
           where wp.WorkshopDayID = @WorkshopDayID)
GO


CREATE FUNCTION [ShowAllWorkshopInConference]
  (
        @ConferenceID int
  )
RETURNS TABLE
AS RETURN (
              SELECT w.WorkshopName, cd.date, wd.startTime, wd.endTime, wd.limit from Conference_Days as cd inner join Workshop_Days as wd on wd.ConferenceDayID = cd.ConferenceDayID inner join workshops as w on w.workshopID = wd.workshopID
                    where @ConferenceID = cd.conferenceID
          )
GO