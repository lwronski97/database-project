-- participant informations

create view V_Participant_Informations as
  select ParticipantID, FirstName, LastName, Phone
  from Participants pa
         inner join Persons pe on pa.PersonID = pe.PersonID

-- canceled conferences (possible?)


-- canceled workshops (possible?)


-- conference day participants

create view V_Conference_Day_Participants as
  select cd.ConferenceDayID, p.ParticipantID, pe.FirstName, pe.LastName
  from Conference_Days cd
         inner join Order_Days od on cd.ConferenceDayID = od.ConferenDayID
         inner join Participants p on p.OrderDayID = od.OrderDayID
         inner join Persons pe on p.PersonID = pe.PersonID

-- conference day informations

create view V_Conference_Day_Informations as
  select cd.ConferenceDayID, cd.Date, od.NormalTickets, od.StudentTickets
  from Conference_Days cd
         inner join Order_Days od on cd.ConferenceDayID = od.ConferenDayID

-- workshop day participants

create view V_Workshop_Day_Participants as
  select wd.WorkshopDayID, wp.ParticipantID, pe.FirstName, pe.LastName
  from Workshop_Days wd
         left join Workshop_Participants wp on wd.WorkshopDayID = wp.WorkshopDayID
         left join Participants p on wp.ParticipantID = p.ParticipantID
         left join Persons pe on p.PersonID = pe.PersonID

-- workshop informations

create view V_Workshop_Day_Informations as
  select wd.WorkshopDayID, w.WorkshopName, cd.Date, wd.StartTime, wd.EndTime, o.CompanyName as OrganizerName
  from Workshop_Days wd
         inner join Conference_Days cd on cd.ConferenceDayID = wd.ConferenceDayID
         inner join Workshops w on w.WorkshopID = wd.WorkshopID
         inner join Organizers o on w.OrganizerID = o.OrganizerID

-- client payments

create view V_Client_Payments as
  select c.ClientID,
         o.OrderID,
         o.OrderDate,
         o.PaymentDate,
         (ISNULL(od.StudentTickets, 0) * (1 - co.StudentDiscount) * (1 - p.Discount)) as 'Student tickets price',
         (od.NormalTickets * (1 - p.Discount))                                        as 'Normal tickets price'
  from Clients c
         left join Orders o on c.ClientID = o.ClientID
         left join Order_Days od on o.OrderID = od.OrderID
         left join Conference_Days cd on od.OrderDayID = cd.ConferenceDayID
         left join Conferences co on cd.ConferenceID = co.ConferenceID
         left join Prices p on co.ConferenceID = p.ConferenceID and o.OrderDate between p.StartDate and p.EndDate
  where DATEDIFF(day, PaymentDate, OrderDate) < 8

-- common clients

create view V_Common_Clients as
  select top 5 with ties o.ClientID, count(o.OrderID) as 'How many times'
  from Orders o
  where DATEDIFF(day, PaymentDate, OrderDate) < 8          --!!zmienić w bazie!!
  group by o.ClientID
  order by 2 desc

-- canceled reservations

create view V_Canceled_Reservations as
  select o.OrderID, o.ClientID
  from Orders o
  where DATEDIFF(day, PaymentDate, OrderDate) > 7

-- after consultations:

-- workshop days in conferences

create view V_Conference_Workshops_Days as
  select c.ConferenceID, c.ConferenceName, wd.WorkshopDayID, w.WorkshopName, wd.StartTime, wd.EndTime, cd.date
  from Conferences c
         left join Conference_Days cd on c.ConferenceID = cd.ConferenceID
         left join Workshop_Days wd on cd.ConferenceDayID = wd.ConferenceDayID
         left join Workshops w on wd.WorkshopID = w.WorkshopID

-- conference participants information

create view V_Conference_Participants_information as
  select cd.ConferenceID, p.ParticipantID, pe.FirstName, pe.LastName, co.CompanyName
  from Conference_Days cd
         inner join Order_Days od on cd.ConferenceDayID = od.ConferenDayID
         inner join Participants p on p.OrderDayID = od.OrderDayID
         inner join Persons pe on p.PersonID = pe.PersonID
         inner join Orders o on od.OrderID = o.OrderID
         inner join Clients cl on o.ClientID = cl.ClientID
         inner join Companies co on cl.ClientID = co.ClientID
  order by 1
