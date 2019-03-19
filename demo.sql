-- add country

BEGIN
  DECLARE @countyID int
  exec FindCountry 'test', @countyID out
END

select * from countries;

-- add city

BEGIN
  DECLARE @CityID int
  exec FindCity 'test', 'test', @cityID out
END

select * from cities;

BEGIN
  DECLARE @clientID int
  exec InsertClient 'test@test.test', 'test', 'test', 'test', @clientID out
END


-- add organizer

select * from organizers

BEGIN
  DECLARE @organizerID int
  exec AddOrganizer 'kupa', '23@ds.test', '23223', '233',  @organizerID out
END

select *
from conferences;
select *
from Conference_Days;


-- add conference

BEGIN
  DECLARE @conferenceID int
  exec AddConference 1, 'sdsdsd', 0, '233', 'test', 'dupa', '2008-12-10', '2008-12-20', 5, 3, @conferenceID out
END

-- ConferenceDayCheckDate


INSERT INTO Conference_Days (ConferenceID, Date) VALUES (3, '2008-11-17')


select * from conferences;

-- add price level

select * from prices;

BEGIN
  exec AddPriceLevel 3, '2008-02-09', '2008-11-15', 0.15
END

INSERT INTO Prices (ConferenceID, StartDate, EndDate, Discount) VALUES (6, '2008-02-08', '2008-02-19', 0.5)

-- trigger add price level

INSERT INTO Prices (ConferenceID, StartDate, EndDate, Discount) VALUES (3,  '2008-02-11', '2008-02-12', 0.15)


-- add workshop

select *
from organizers;

select *
from workshops;

BEGIN
  DECLARE @workshopID int
  exec AddWorkshop 1, 'dupa', @workshopID out
END

-- add workshop day to conference day

select *
from workshops;
select *
from Conferences

select *
from Conference_Days;

BEGIN
  DECLARE @workshopID int
  exec AddWorkshopDay 3, 3, '2008-11-11', '11:00', '12:54', 30, 60, @workshopID out
END

select * from Workshop_Days

INSERT INTO [Workshop_Days] (WorkshopID, ConferenceDayID, StartTime, EndTime, Limit, Price) VALUES  ( 2, 7, '10:34', '10:54', 10, 3 )

-- add client business


BEGIN
  DECLARE @clientID int
  exec AddClientBusiness 'test7', '500318151', 'test', 'test', '4343@test.ds2sfdd', 'test', 'test', 'test', @clientID out
END

select * from clients
select * from companies

-- insert persons


BEGIN
  DECLARE @PersonID int
  exec InsertPerson 'test', 'test', '500318151', @PersonID out
END

-- add client individual


BEGIN
  DECLARE @clientID int
  exec AddClientIndividual 'kupa', 'dupa', '500318152', 'dupa@test.emial', '4343@ds2sfdd', 'test', 'test', @clientID out
END

select * from Individual_Clients
select * from persons

-- add employee to companies

select *
from companies;

BEGIN
  DECLARE @personID int
  exec AddEmployee 2, 'dupa', 'kupa', '500318154', @personID out
END

select * from persons
select * from employees

-- add order

select *
from clients;
select *
from orders;

BEGIN
  DECLARE @orderID int
  exec AddOrder 5, '2008-10-11', @orderID out
END


select * from conference_days

select ( dbo.GetFreePlacesConferenceDay(1))

-- add conference day to order day add order day

select *
from orders;
select *
from Conference_Days;
select * from conferences

BEGIN
  DECLARE @orderDayID int
  exec AddOrderDay 5, 6, '2008-12-10', 2, 0, @orderDayID out
END

select * from order_days

-- add order day range

exec AddRangeOrderDay 3, 5 , '2008-12-14' , '2008-12-15' , 0, 2


INSERT INTO [Order_Days] (OrderID, ConferenceDayID, NormalTickets, StudentTickets) VALUES (2, 3, 4, 0)


-- add workshop order

select *
from Order_Days;

select *
from Workshop_Days;

BEGIN
  DECLARE @workshopOrderID int
  exec AddWorkshopOrder 3, 3, 0, 1, @workshopOrderID out
END

select * from Workshop_Orders

-- add person

select *
from persons;

BEGIN
  DECLARE @PersonID int
  exec FindOrCreatePerson 'dupa', 'kupa', NULL , @PersonID output
  print CAST(@PersonID AS VARCHAR)
END


-- add participant to conference day

select *
from Order_Days;

select *
from persons;

BEGIN
  DECLARE @ParticipantID int
  exec AddParticipantToConferenceDay 19, NULL, NULL, NULL, NULL, @ParticipantID out
END

select * from participants

-- add participant to workshop day

select *
from participants;
select *
from Workshop_Days;


BEGIN
  exec AddParticipantToWorkshopDay 3, 2
END

INSERT INTO Workshop_Participants (ParticipantID, WorkshopDayID)
VALUES (1, 16);



select *
from Workshop_Participants

-- update person data
select *
from persons;

BEGIN
  exec UpdatePersonData 6, 'test', 'test', 500318121
END

-- remove canceled orders

exec RemoveCancelOrders

-- pay reservation
select *
from orders;

BEGIN
  exec PayReservation 1
END

-- update person data

select * from persons

exec UpdatePersonData 10, 'test', 'test', NUll

-- get price order

select * from orders

select ( dbo.GetOrderNormalPriceTicket(2, '2008-02-10'))

select ( dbo.GetPriceOrder(5, '2008-02-10'));

(Select Sum(NormalTickets) * (2.55) +
                                             Sum(StudentTickets) * (2.55) * (1 - 0)
                                      From [Order_Days] as od
                                      WHERE od.orderID = 2)

select * from dbo.GetConferenceDaysList(2)

select * from workshop_participants

select * from dbo.ShowAllWorkshopInConference(2)

