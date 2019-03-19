-- tables

--Person


CREATE TABLE [Persons] (
  [PersonID]  [int]          NOT NULL identity,
  [FirstName] [varchar](256) NULL,
  [LastName]  [varchar](256) NULL,
  [Phone]     [varchar](256) NULL,
  CONSTRAINT validat_phone_person CHECK ( PHONE IS NULL or (ISNUMERIC(Phone) = 1 and LEN(Phone) = 9) or ( LEN(Phone) = 12 and phone  LIKE '+%' and ISNUMERIC(SUBSTRING(Phone,2,12)) = 1 )),
  CONSTRAINT [PK_Person] PRIMARY KEY ([PersonID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]



-- employees

CREATE TABLE [Employees] (
  [PersonID]  [int] NOT NULL,
  [CompanyID] [int] NOT NULL,
  CONSTRAINT [PK_Employees] PRIMARY KEY ([PersonID], [CompanyID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [Employees]
  ADD CONSTRAINT [FK_Employees_Companies] FOREIGN KEY ([CompanyID])
REFERENCES [Companies] ([CompanyID])



ALTER TABLE [Employees]
  ADD CONSTRAINT [FK_Employees_Person] FOREIGN KEY ([PersonID])
REFERENCES [Persons] ([PersonID])

-- companies

CREATE TABLE [Companies] (
  [CompanyID]   [int]          NOT NULL IDENTITY,
  [CompanyName] [varchar](256) NOT NULL,
  [Adress]      [varchar](256) NOT NULL,
  [NIP]         [varchar](256) NOT NULL,
  [ClientID]    [int]          NOT NULL,
  [Phone]       [varchar](256) NOT NULL,
  CONSTRAINT validat_phone_companies CHECK ( (ISNUMERIC(Phone) = 1 and LEN(Phone) = 9) or ( LEN(Phone) = 12 and phone  LIKE '+%' and ISNUMERIC(SUBSTRING(Phone,0,10)) = 1 )),
  CONSTRAINT unique_NIP_companies UNIQUE (NIP),
  CONSTRAINT [PK_Companies] PRIMARY KEY ([CompanyID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [Companies]
  ADD CONSTRAINT [FK_Companies_Clients] FOREIGN KEY ([ClientID])
REFERENCES [Clients] ([ClientID])


-- clients

CREATE TABLE [Clients] (
  [ClientID] [int]          NOT NULL IDENTITY,
  [Street]   [varchar](256) NOT NULL,
  [CityID]   [int]          NOT NULL,
  [Email]    [varchar](256) NOT NULL,
  CONSTRAINT unique_email UNIQUE (Email),
  CONSTRAINT check_email CHECK (Email LIKE '%_@_%._%'),
  CONSTRAINT [PK_Clients] PRIMARY KEY ([ClientID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Clients]
  ADD CONSTRAINT [FK_Clients_Cities] FOREIGN KEY ([CityID])
REFERENCES [Cities] ([CityId])

-- individual clients

CREATE TABLE [Individual_Clients] (
  [ClientID] [int] NOT NULL,
  [PersonID] [int] NOT NULL,
  CONSTRAINT [PK_Individual_Clients] PRIMARY KEY CLUSTERED ([ClientID], [PersonID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [Individual_Clients]
  ADD CONSTRAINT [FK_Individual_Clients_Clients] FOREIGN KEY ([ClientID])
REFERENCES [Clients] ([ClientID])

ALTER TABLE [Individual_Clients]
  ADD CONSTRAINT [FK_Individual_Clients_Person] FOREIGN KEY ([PersonID])
REFERENCES [Persons] ([PersonID])

-- cities

CREATE TABLE [Cities] (
  [CityId]    [int]          NOT NULL IDENTITY,
  [CityName]  [varchar](256) NOT NULL,
  [CountryID] [int]          NOT NULL,
  CONSTRAINT [PK_Cities] PRIMARY KEY ([CityId] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Cities]
  ADD CONSTRAINT [FK_Cities_Countries] FOREIGN KEY ([CountryID])
REFERENCES [Countries] ([CountryID])

-- countries

CREATE TABLE [Countries] (
  [CountryID]   [int]          NOT NULL IDENTITY,
  [CountryName] [varchar](256) NOT NULL,
  CONSTRAINT unique_country_name UNIQUE (CountryName),
  CONSTRAINT [PK_Countries] PRIMARY KEY ([CountryID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

-- orders

CREATE TABLE [Orders] (
  [OrderID]     [int]      NOT NULL IDENTITY,
  [ClientID]    [int]      NOT NULL,
  [OrderDate]   [date] NOT NULL,
  [PaymentDate] [date] NULL,
  CONSTRAINT validate_payment_date CHECK ( PaymentDate > OrderDate),
  CONSTRAINT [PK_Orders] PRIMARY KEY ([OrderID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Orders]
  ADD CONSTRAINT [FK_Orders_Clients] FOREIGN KEY ([ClientID])
REFERENCES [Clients] ([ClientID])

-- order days


CREATE TABLE [Order_Days] (
  [OrderDayID]     [int] NOT NULL IDENTITY,
  [OrderID]        [int] NOT NULL,
  [ConferenceDayID]  [int] NOT NULL,
  [NormalTickets]  [int] NOT NULL,
  [StudentTickets] [int] NULL DEFAULT (0),
  CONSTRAINT validate_number_normal_ticket CHECK (NormalTickets >=0 ),
  CONSTRAINT unique_order_day_conference UNIQUE (OrderID, ConferenceDayID),
  CONSTRAINT [PK_Order_Days] PRIMARY KEY ([OrderDayID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [Order_Days]
  ADD CONSTRAINT [FK_Order_Days_Conference_Days] FOREIGN KEY ([ConferenceDayID])
REFERENCES [Conference_Days] ([ConferenceDayID])

ALTER TABLE [Order_Days]
  ADD CONSTRAINT [FK_Order_Days_Orders] FOREIGN KEY ([OrderID])
REFERENCES [Orders] ([OrderID])


-- participants


CREATE TABLE [Participants] (
  [ParticipantID] [int] NOT NULL IDENTITY,
  [PersonID]      [int] NOT NULL,
  [OrderDayID]    [int] NOT NULL,
  CONSTRAINT [PK_Participants] PRIMARY KEY ([ParticipantID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Participants]
  ADD CONSTRAINT [FK_Participants_Order_Days] FOREIGN KEY ([OrderDayID])
REFERENCES [Order_Days] ([OrderDayID])

alter table Participants drop constraint  FK_Participants_Person

ALTER TABLE [Participants]
  ADD CONSTRAINT [FK_Participants_Person] FOREIGN KEY ([PersonID])
REFERENCES [Persons] ([PersonID])

-- students


CREATE TABLE [Students] (
  [StudentCardID]  [int] NOT NULL,
  [ParticipantID] [int] NOT NULL,
  CONSTRAINT unique_students UNIQUE (StudentCardID),
  CONSTRAINT [PK_Students_1] PRIMARY KEY ([ParticipantID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Students]
  ADD CONSTRAINT [FK_Students_Participants] FOREIGN KEY ([ParticipantID])
REFERENCES [Participants] ([ParticipantID])

-- conference_days

CREATE TABLE [Conference_Days] (
  [ConferenceDayID] [int] NOT NULL IDENTITY,
  [ConferenceID]    [int] NOT NULL,
  [Date]            [date] NOT NULL,
  CONSTRAINT unique_dat UNIQUE (ConferenceID, Date),
  CONSTRAINT [PK_Conference_Days] PRIMARY KEY ([ConferenceDayID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Conference_Days]
  ADD CONSTRAINT [FK_Conference_Days_Conferences] FOREIGN KEY ([ConferenceID])
REFERENCES [Conferences] ([ConferenceID])

-- conference

CREATE TABLE [Conferences] (
  [ConferenceID]    [int]          NOT NULL IDENTITY,
  [ConferenceName]   [varchar](256) NOT NULL,
  [StudentDiscount] [float]        NOT NULL,
  [Adress]          [varchar](256) NOT NULL,
  [CityID]          [int]          NOT NULL,
  [BeginDate]       [date]         NOT NULL,
  [EndDate]         [date]         NOT NULL,
  [Limit]           [int]          NOT NULL,
  [BasePrice]       [money]        NOT NULL,
  CONSTRAINT later_date CHECK (EndDate >= BeginDate),
  CONSTRAINT positive_limit CHECK (limit > 0),
  CONSTRAINT positive_price CHECK (BasePrice >= 0),
  CONSTRAINT chech_student_discount CHECK ( StudentDiscount  >=  0 and StudentDiscount  <=1 ),
  CONSTRAINT [PK_Conferences] PRIMARY KEY ([ConferenceID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON
    )
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Conferences]
  ADD CONSTRAINT [FK_Conferences_Cities] FOREIGN KEY ([CityID])
REFERENCES [Cities] ([CityId])


-- prices

CREATE TABLE [Prices] (
  [PriceID]      [int]   NOT NULL IDENTITY,
  [ConferenceID] [int]   NOT NULL,
  [StartDate]    [date]  NOT NULL,
  [EndDate]      [date]  NOT NULL,
  [Discount]     [float] NOT NULL,
  CONSTRAINT validate_date CHECK ( EndDate >= StartDate),
  CONSTRAINT chec_discount CHECK (  Discount  >=  0 and Discount  <= 1 ),
  CONSTRAINT [PK_Prices] PRIMARY KEY ([PriceID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [Prices]
  ADD CONSTRAINT [FK_Prices_Conferences] FOREIGN KEY ([ConferenceID])
REFERENCES [Conferences] ([ConferenceID])


-- workshop-order

CREATE TABLE [Workshop_Orders] (
  [WorkshopOrderID] [int] NOT NULL IDENTITY,
  [WorkshopDayID]   [int] NOT NULL,
  [OrderDayID]      [int] NOT NULL,
  [NormalTickets]   [int] NOT NULL,
  [StudentTickets] [int] NULL DEFAULT (0),
  CONSTRAINT validate_number_normal_ticket_workshop CHECK (NormalTickets >= 0 ),
  CONSTRAINT validate_number_student_ticket_workshop CHECK (StudentTickets >= 0 ),
  CONSTRAINT unique_workshop_in_order UNIQUE (WorkshopDayID, OrderDayID),
  CONSTRAINT [PK_Workshop_Order] PRIMARY KEY ([WorkshopOrderID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Workshop_Orders]
  ADD CONSTRAINT [FK_Workshop_Order_Order_Days] FOREIGN KEY ([OrderDayID])
REFERENCES [Order_Days] ([OrderDayID])

ALTER TABLE [Workshop_Orders]
  ADD CONSTRAINT [FK_Workshop_Order_Workshop_Days] FOREIGN KEY ([WorkshopDayID])
REFERENCES [Workshop_Days] ([WorkshopDayID])

-- workshop_days


CREATE TABLE [Workshop_Days] (
  [WorkshopDayID]   [int]   NOT NULL IDENTITY,
  [WorkshopID]      [int]   NOT NULL,
  [ConferenceDayID] [int]   NOT NULL,
  [StartTime]       [time]  NOT NULL,
  [EndTime]         [time]  NOT NULL,
  [Limit]           [int]   NOT NULL,
  [Price]           [money] NULL,
  CONSTRAINT validate_workshop_time CHECK ( EndTime  >  StartTime),
  CONSTRAINT validate_limit CHECK ( limit >= 0 ),
  CONSTRAINT validate_price CHECK ( Price >= 0 ),
  CONSTRAINT [PK_Workshop_Days] PRIMARY KEY ([WorkshopDayID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [Workshop_Days]
  ADD CONSTRAINT [FK_Workshop_Days_Conference_Days] FOREIGN KEY ([ConferenceDayID])
REFERENCES [Conference_Days] ([ConferenceDayID])


ALTER TABLE [Workshop_Days]
  ADD CONSTRAINT [FK_Workshop_Days_Workshop] FOREIGN KEY ([WorkshopID])
REFERENCES [Workshops] ([WorkshopID])

-- workshop participants

CREATE TABLE [Workshop_Participants](
	[WorkshopDayID] [int] NOT NULL,
	[ParticipantID] [int] NOT NULL
  CONSTRAINT [PK_Workshop_Participants] PRIMARY KEY CLUSTERED ([WorkshopDayID], [ParticipantID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [Workshop_Participants] ADD  CONSTRAINT [FK_WorkshopParticipant_Participants1] FOREIGN KEY([ParticipantID])
REFERENCES [Participants] ([ParticipantID])

ALTER TABLE [Workshop_Participants] ADD  CONSTRAINT [FK_WorkshopParticipant_Workshop_Days] FOREIGN KEY([WorkshopDayID])
REFERENCES [Workshop_Days] ([WorkshopDayID])


-- workshop

CREATE TABLE [Workshops] (
  [WorkshopID]   [int]          NOT NULL IDENTITY,
  [OrganizerID]  [int]          NOT NULL,
  [WorkshopName] [varchar](256) NOT NULL,
  CONSTRAINT [PK_Workshop] PRIMARY KEY ([WorkshopID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [Workshops]
  ADD CONSTRAINT [FK_Workshop_Organizers] FOREIGN KEY ([OrganizerID])
REFERENCES [Organizers] ([OrganizerID])


-- organizers


CREATE TABLE [Organizers] (
  [OrganizerID] [int]          NOT NULL IDENTITY,
  [CompanyName] [varchar](256) NOT NULL,
  [Phone]       [varchar](256) NOT NULL,
  [Adress]      [varchar](256) NOT NULL,
  [Email]       [varchar](256) NOT NULL,
  CONSTRAINT validat_phone_person CHECK ( PHONE IS NULL or (ISNUMERIC(Phone) = 1 and LEN(Phone) = 9) or ( LEN(Phone) = 12 and phone  LIKE '+%' and ISNUMERIC(SUBSTRING(Phone,2,12)) = 1 )),
  CONSTRAINT check_email_organizers CHECK (Email LIKE '%_@_%._%'),
  CONSTRAINT [PK_Organizers] PRIMARY KEY CLUSTERED ([OrganizerID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]

-- conference organizers

CREATE TABLE [Conference_Organizers] (
  [ConferenceID] [int] NOT NULL,
  [OrganizerID]  [int] NOT NULL,
  CONSTRAINT [PK_Conference_Organizers] PRIMARY KEY ([ConferenceID], [OrganizerID] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
      IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
    ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [Conference_Organizers]
  ADD CONSTRAINT [FK_Conference_Organizers_Conferences] FOREIGN KEY ([ConferenceID])
REFERENCES [Conferences] ([ConferenceID])


ALTER TABLE [Conference_Organizers]
  ADD CONSTRAINT [FK_Conference_Organizers_Organizers] FOREIGN KEY ([OrganizerID])
REFERENCES [Organizers] ([OrganizerID])

