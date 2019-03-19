CREATE PROCEDURE [FindCountry] -- done
    @countryName varchar(255),
    @countryID   int OUTPUT
AS
  SET NOCOUNT ON
  BEGIN TRY

  BEGIN TRANSACTION

  SET @countryID = dbo.getCountryID(@countryName)

  IF (@countryID is null)
    BEGIN
      INSERT INTO Countries (CountryName) VALUES (@countryName);
      SET @countryID = @@IDENTITY;
    END

  COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add Country' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH

GO

CREATE PROCEDURE [FindCity] -- done
    @cityName    varchar(255),
    @countryName varchar(255),
    @cityID      int OUTPUT
AS
  SET NOCOUNT ON
  BEGIN TRY

  BEGIN TRANSACTION

  DECLARE @countryID int

  EXEC FindCountry
      @countryName,
      @countryID = @countryID out

  SET @cityID = dbo.getCityID(@countryID, @cityName)

  IF (@cityID is null)
    BEGIN
      INSERT INTO Cities (CityName, CountryID) VALUES (@cityName, @countryID);
      SET @cityID = @@IDENTITY;
    END

  COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add City' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH

GO


CREATE PROCEDURE [InsertClient] -- done
    @email       varchar(255),
    @street      varchar(255),
    @cityName    varchar(255),
    @countryName varchar(255),
    @clientID    int OUTPUT
AS

  SET NOCOUNT ON
  BEGIN TRY

  BEGIN TRANSACTION

  DECLARE @cityID int

  EXEC FindCity
      @cityName,
      @countryName,
      @cityID = @cityID OUTPUT

  INSERT INTO Clients (Email, Street, CityID)
  VALUES (@email, @Street, @cityID);
  SET @clientID = @@IDENTITY


  COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with insert Client' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH

GO


CREATE PROCEDURE [InsertPerson] -- done
    @firstName varchar(255),
    @lastname  varchar(255),
    @phone     varchar(255),
    @personID  int OUTPUT
AS
  SET NOCOUNT ON

  BEGIN
    INSERT INTO Persons (Firstname, Lastname, Phone) VALUES (@firstname, @lastname, @phone);
    SET @personID = @@IDENTITY
  END
GO


CREATE PROCEDURE [AddClientBusiness] -- done
    @companyName varchar(255),
    @phone       varchar(255),
    @address     varchar(255),
    @nip         varchar(255),
    @email       varchar(255),
    @street      varchar(255),
    @cityName    varchar(255),
    @countryName varchar(255),
    @clientID    int OUTPUT
AS
  SET NOCOUNT ON

  BEGIN TRY

  BEGIN TRANSACTION


  EXEC InsertClient
      @email,
      @street,
      @cityName,
      @countryName,
      @clientID = @clientID OUTPUT

  INSERT INTO Companies (CompanyName, Phone, Adress, NIP, ClientID)
  VALUES (@companyName, @phone, @address, @nip, @clientID);

  COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add client business:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH

GO

drop procedure AddClientIndividual

CREATE PROCEDURE [AddClientIndividual] -- done
    @firstname   varchar(255),
    @lastname    varchar(255),
    @phone       varchar(255),
    @email       varchar(255),
    @street      varchar(255),
    @cityName    varchar(255) = NULL,
    @countryName varchar(255) = NULL,
    @clientID    int OUTPUT
AS
  SET NOCOUNT ON


  BEGIN TRY

  BEGIN TRANSACTION

  DECLARE @personID int

  EXEC InsertClient
      @email,
      @street,
      @cityName,
      @countryName,
      @clientID = @clientID OUTPUT

  EXEC InsertPerson
      @firstname,
      @lastname,
      @phone,
      @personID = @personID OUTPUT

  INSERT INTO [Individual_Clients] (ClientID, PersonID)
  VALUES (@clientID, @personID);

  COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add individual business:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


CREATE PROCEDURE [AddEmployee] -- done
    @companyID INT,
    @firstname varchar(255),
    @lastname  varchar(255),
    @phone     varchar(255),
    @personID  INT OUTPUT
AS

  SET NOCOUNT ON


  BEGIN TRY

  BEGIN TRANSACTION

  EXEC InsertPerson
      @firstname,
      @lastname,
      @phone,
      @personID = @personID OUTPUT

  INSERT INTO Employees (PersonID, CompanyID)
  VALUES (@personID, @companyID);

  COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add employee:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


CREATE PROCEDURE [AddOrganizer] -- done
    @companyName varchar(255),
    @email       varchar(255),
    @phone       varchar(255),
    @adress      varchar(255),
    @organizerID INT OUTPUT
AS

  SET NOCOUNT ON

  BEGIN

    INSERT INTO Organizers (CompanyName, Phone, Adress, Email) VALUES (@companyName, @phone, @adress, @email);
    SET @organizerID = @@IDENTITY

  END

GO

CREATE PROCEDURE [AddConference] -- done
    @organizerID     int,
    @conferenceName  varchar(255),
    @studentDiscount float,
    @address         varchar(255),
    @cityName        varchar(255),
    @countryName     varchar(255),
    @beginDate       date,
    @endDate         date,
    @limit           int,
    @basePrice       money,
    @conferenceID    int out
AS

  SET NOCOUNT ON

  BEGIN TRY

  BEGIN TRANSACTION

  DECLARE @cityID int

  EXEC FindCity
      @cityName,
      @countryName,
      @cityID = @cityID out

  INSERT INTO Conferences (ConferenceName, StudentDiscount, Adress, CityID, BeginDate, EndDate, Limit, BasePrice)
  VALUES (@conferenceName, @studentDiscount, @address, @cityID, @beginDate, @endDate, @limit, @basePrice);
  SET @conferenceID = @@IDENTITY;

  INSERT INTO [Conference_Organizers] (ConferenceID, OrganizerID)
  values (@conferenceID, @organizerID)

  DECLARE @i date = @beginDate

  WHILE @i <= @endDate
    BEGIN
      INSERT INTO [Conference_Days] (ConferenceID, Date) VALUES (@conferenceID, @i)
      SET @i = DATEADD(d, 1, @i)
    END

  COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with create conference:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


CREATE PROCEDURE [AddPriceLevel] -- done
    @conferenceID int,
    @startDate    date,
    @endDate      date,
    @discount     float
AS

  SET NOCOUNT ON
  BEGIN TRY

  BEGIN TRANSACTION

  IF (@endDate >= (select beginDate
                   from Conferences
                   where @conferenceID = conferenceID))
    BEGIN
      ;
      THROW 50002, 'price thresholds can not end before the conference begins', 1;
    end

  IF EXISTS(SELECT *
            from Prices
            where @conferenceID = conferenceID
              and (startDate <= @endDate and endDate >= @startDate))
    BEGIN
      ;
      THROW 50002, 'two prices overlap date', 1;
    end


  INSERT INTO Prices (ConferenceID, StartDate, EndDate, Discount)
  VALUES (@conferenceID, @startDate, @endDate, @discount)


  COMMIT TRANSACTION

  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add price level:' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


CREATE PROCEDURE [AddOrder] -- need work
    @ClientID  int,
    @OrderDate date,
    @orderID   int out
AS
  BEGIN TRY
  BEGIN TRANSACTION

  INSERT INTO Orders (ClientID, OrderDate)
  VALUES (@ClientID, @OrderDate)
  SET @orderID = @@IDENTITY

  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add order:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


select *
from orders;

drop procedure AddOrderDay

CREATE PROCEDURE [AddOrderDay] -- need work
    @orderID        int,
    @conferenceID   int,
    @date           date,
    @normalTickets  int,
    @studentTickets int,
    @orderDayID     int out
AS
  SET NOCOUNT ON
  BEGIN TRY
  BEGIN TRANSACTION

  DECLARE @conferenceDayID int
  SET @conferenceDayID = (SELECT conferenceDayID
                          from Conference_Days as cd
                          where cd.conferenceID = @conferenceID
                            and cd.Date = @date)

  IF (@conferenceDayID is null)
    BEGIN
      ;
      THROW 50002, 'Not exists conference day', 1;
    end


  IF EXISTS(SELECT *
            from Order_Days
            where @conferenceDayID = ConferenceDayID
              and @orderID = orderID)
    BEGIN
      ;
      THROW 50002, 'Day reservation already exists', 1;
    end

  IF ((SELECT PaymentDate
       from orders
       where @orderID = orderID) is not null)
    BEGIN
      ;
      THROW 50002, 'the reservation is already paid', 1;
    end

  IF (ISNULL(dbo.GetFreePlacesConferenceDay(@conferenceDayID), 0) < @normalTickets + @studentTickets)
    BEGIN
      ;
      THROW 50002, 'No vacancies in conference', 1;
    end

  INSERT INTO [Order_Days] (OrderID, ConferenceDayID, NormalTickets, StudentTickets)
  VALUES (@orderID, @conferenceDayID, @normalTickets, @studentTickets)
  SET @orderDayID = @@IDENTITY

  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add order:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO

CREATE PROCEDURE [AddRangeOrderDay]
    @orderID     int,
    @conferenceID   int,
    @beginDate      date,
    @endDate        date,
    @normalTickets  int,
    @studentTickets int
AS
  SET NOCOUNT ON
  BEGIN TRY
  BEGIN TRANSACTION

  DECLARE @i date = @beginDate

  WHILE @i <= @endDate
    BEGIN
      BEGIN
        DECLARE @orderDayID int
        exec AddOrderDay @orderId, @conferenceID, @i, @normalTickets, @studentTickets, @orderDayID out
      END
      SET @i = DATEADD(d, 1, @i)
    END


  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add participant to conference day:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


CREATE PROCEDURE [AddWorkshop] -- done
    @organizerID  int,
    @workshopName varchar(255),
    @workshopID   int out
AS
  BEGIN
    SET NOCOUNT ON;
    INSERT INTO Workshops (OrganizerID, WorkshopName) VALUES (@organizerID, @workshopName)
    SET @workshopID = @@IDENTITY
  END
GO


CREATE PROCEDURE [AddWorkshopDay] -- done
    @workshopID    int,
    @conferenceID  int,
    @date          date,
    @startTime     time,
    @endTime       time,
    @limit         int,
    @price         money,
    @workshopDayID int out
AS
  SET NOCOUNT ON
  BEGIN TRY
  BEGIN TRANSACTION

  DECLARE @conferenceDayID int = dbo.getConferenceDayID(@conferenceID, @date)

  IF (@conferenceDayID is null)
    BEGIN
      ;
      THROW 50001, 'Conferences in day not exists', 1;
    END

  IF (dbo.GetLimitConference(@conferenceID) < @limit)
    BEGIN
      ;
      THROW 50001, 'Too small places limit Conference', 1;
    end

  INSERT INTO [Workshop_Days] (WorkshopID, ConferenceDayID, StartTime, EndTime, Limit, Price)
  VALUES (@workshopID, @conferenceDayID, @startTime, @endTime, @limit, @price)
  SET @workshopDayID = @@IDENTITY

  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add order or:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO

drop procedure AddWorkshopOrder

CREATE PROCEDURE [AddWorkshopOrder] -- done // need test
    @orderDayID      int,
    @workshopDayID   int,
    @normalTickets   int,
    @studentTickets  int,
    @workshopOrderID int out
AS
  SET NOCOUNT ON

  BEGIN TRY
  BEGIN TRANSACTION

  IF ((SELECT o.PaymentDate
       from orders as o
              inner join Order_Days as od on od.OrderID = o.OrderID
       where @OrderDayID = od.orderID) is not null)
    BEGIN
      ;
      THROW 50002, 'the reservation is already paid', 1;
    end

  IF EXISTS(SELECT *
            from Workshop_Orders
            where @WorkshopDayID = workshopDayID
              and @orderDayID = orderDayID)
    BEGIN
      ;
      THROW 50002, 'Workshop Day reservation already exists', 1;
    end

  IF ((SELECT ConferenceDayID
       from Order_Days
       where OrderDayID = @OrderDayID) <> (SELECT ConferenceDayID
                                           from Workshop_Days
                                           where workshopDayID = @workshopDayID))
    BEGIN
      ;
      THROW 50002, 'Not the same conference day', 1;
    end

  IF (dbo.GetFreePlacesWorkshopDay(@workshopDayID) < @normalTickets + @studentTickets)
    BEGIN
      ;
      THROW 50002, 'Lack of free pkace in workshop day', 1;
    end


  INSERT INTO [Workshop_Orders] (OrderDayID, WorkshopDayID, NormalTickets, StudentTickets)
  VALUES (@orderDayID, @workshopDayID, @normalTickets, @studentTickets)
  SET @workshopOrderID = @@IDENTITY

  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add order or:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


CREATE PROCEDURE [PayReservation]
    @orderID int
AS
  BEGIN
    IF ((Select PaymentDate FROM Orders WHERE OrderID = @orderID) is not null)
      BEGIN
        THROW 50001, 'The reservation is paid', 1;
      END

    UPDATE Orders SET PaymentDate = GETDATE() WHERE OrderID = @orderID
  END
GO


CREATE PROCEDURE [RemoveCancelOrders]
AS
  BEGIN
    DELETE FROM Orders WHERE PaymentDate is null
                         and DATEDIFF(d, OrderDate, GETDATE()) >= 7
  END
GO

CREATE PROCEDURE [FindOrCreatePerson] -- done
    @FirstName varchar(255),
    @LastName  varchar(255),
    @Phone     varchar(255),
    @PersonID  int output
AS
  BEGIN

    SET @personID = (Select PersonID From persons Where FirstName = @FirstName
                                                    and LastName = @LastName
                                                    and Phone = @Phone)

    IF (@PersonID is not null)
      RETURN @PersonID

    BEGIN
      INSERT INTO Persons (FirstName, LastName, Phone) VALUES (@FirstName, @LastName, @Phone);
      SET @PersonID = @@IDENTITY;
    END

  END
GO


CREATE PROCEDURE [AddParticipantToConferenceDay]
    @OrderDayID    int,
    @FirstName     varchar(255),
    @LastName      varchar(255),
    @Phone         varchar(255),
    @StudentCardID int,
    @ParticipantID int output
AS
  SET NOCOUNT ON
  BEGIN TRY
  BEGIN TRANSACTION

  DECLARE @PersonID int
  EXEC dbo.FindOrCreatePerson  @FirstName, @LastName, @Phone, @PersonID out

  DECLARE @CompanyClientID int
  SET @CompanyClientID = (SELECT companies.companyID
                          from Order_Days as od
                                 inner join orders as o on o.orderID = od.orderID
                                 inner join clients as c on c.ClientID = o.ClientID
                                 inner join companies on companies.clientID = c.ClientID
                          where od.OrderDayID = @OrderDayID)
  IF (@CompanyClientID IS NOT NULL AND @PersonID NOT IN (SELECT PersonID
                                                         from employees as e
                                                         where e.CompanyID = @CompanyClientID))
    INSERT INTO employees (PersonID, CompanyID)
    VALUES (@PersonID, @CompanyClientID)

  BEGIN
    INSERT INTO participants (PersonID, OrderDayID) VALUES (@PersonID, @OrderDayID)

  END

  IF (@StudentCardID IS NOT NULL)
    INSERT INTO students (StudentCardID, ParticipantID)
    VALUES (@StudentCardID, @ParticipantID)

  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add participant to conference day:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO

CREATE PROCEDURE [AddNParticipantToConferenceDay]
    @OrderDayID int,
    @number     int
AS
  SET NOCOUNT ON
  BEGIN TRY
  BEGIN TRANSACTION

  DECLARE @Counter int
  SET @Counter = 1

  WHILE @Counter <= @number
    BEGIN
      DECLARE @ParticipantID int
      exec AddParticipantToConferenceDay @OrderDayID, NULL, NULL, NULL, NULL, @ParticipantID out
      SET @Counter = @Counter + 1
    END


  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add participant to conference day:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


select *
from participants;

select *
from employees;


CREATE PROCEDURE [AddParticipantToWorkshopDay]
    @WorkshopDayID int,
    @ParticipantID int
AS
  SET NOCOUNT ON
  BEGIN TRY
  BEGIN TRANSACTION

  INSERT INTO Workshop_Participants (ParticipantID, WorkshopDayID)
  VALUES (@ParticipantID, @WorkshopDayID)

  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with add participant to workshop day:' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO


CREATE PROCEDURE [UpdatePersonData]
    @PersonID  int,
    @FirstName varchar(255),
    @LastName  varchar(255),
    @Phone     varchar(255)
AS
  SET NOCOUNT ON
  BEGIN TRY
  BEGIN TRANSACTION
  UPDATE Persons
  SET FirstName = @FirstName,
      LastName  = @LastName,
      Phone     = @Phone
  WHERE personID = @PersonID
  COMMIT TRANSACTION
  END TRY

  BEGIN CATCH
  ROLLBACK TRANSACTION
  DECLARE @msg NVARCHAR(2048) = 'Error with update person data' + ERROR_MESSAGE();
  THROW 50001, @msg, 1;

  END CATCH
GO

