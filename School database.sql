/*
	Sample School Database
	SQL Server / T-SQL

	Review this script before executing it. It creates a new database named SchoolDemo.
*/

USE [master];
GO

IF DB_ID(N'SchoolDemo') IS NULL
BEGIN
	CREATE DATABASE [SchoolDemo];
END;
GO

USE [SchoolDemo];
GO

/* Reference and organization tables */
CREATE TABLE dbo.AcademicYears
(
	AcademicYearId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_AcademicYears PRIMARY KEY,
	YearName nvarchar(20) NOT NULL CONSTRAINT UQ_AcademicYears_YearName UNIQUE,
	StartDate date NOT NULL,
	EndDate date NOT NULL,
	IsCurrent bit NOT NULL CONSTRAINT DF_AcademicYears_IsCurrent DEFAULT (0),
	CONSTRAINT CK_AcademicYears_Dates CHECK (EndDate > StartDate)
);
GO

CREATE TABLE dbo.Terms
(
	TermId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Terms PRIMARY KEY,
	AcademicYearId int NOT NULL,
	TermName nvarchar(30) NOT NULL,
	StartDate date NOT NULL,
	EndDate date NOT NULL,
	CONSTRAINT FK_Terms_AcademicYears FOREIGN KEY (AcademicYearId) REFERENCES dbo.AcademicYears(AcademicYearId),
	CONSTRAINT UQ_Terms_YearName UNIQUE (AcademicYearId, TermName),
	CONSTRAINT CK_Terms_Dates CHECK (EndDate > StartDate)
);
GO

CREATE TABLE dbo.Departments
(
	DepartmentId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Departments PRIMARY KEY,
	DepartmentName nvarchar(100) NOT NULL CONSTRAINT UQ_Departments_Name UNIQUE,
	Description nvarchar(500) NULL
);
GO

CREATE TABLE dbo.Buildings
(
	BuildingId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Buildings PRIMARY KEY,
	BuildingName nvarchar(100) NOT NULL CONSTRAINT UQ_Buildings_Name UNIQUE
);
GO

CREATE TABLE dbo.Rooms
(
	RoomId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Rooms PRIMARY KEY,
	BuildingId int NOT NULL,
	RoomNumber nvarchar(20) NOT NULL,
	Capacity int NOT NULL,
	CONSTRAINT FK_Rooms_Buildings FOREIGN KEY (BuildingId) REFERENCES dbo.Buildings(BuildingId),
	CONSTRAINT UQ_Rooms_BuildingNumber UNIQUE (BuildingId, RoomNumber),
	CONSTRAINT CK_Rooms_Capacity CHECK (Capacity > 0)
);
GO

/* People */
CREATE TABLE dbo.Teachers
(
	TeacherId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Teachers PRIMARY KEY,
	DepartmentId int NULL,
	EmployeeNumber varchar(20) NOT NULL CONSTRAINT UQ_Teachers_EmployeeNumber UNIQUE,
	FirstName nvarchar(50) NOT NULL,
	LastName nvarchar(50) NOT NULL,
	Email varchar(255) NOT NULL CONSTRAINT UQ_Teachers_Email UNIQUE,
	Phone varchar(30) NULL,
	HireDate date NOT NULL,
	IsActive bit NOT NULL CONSTRAINT DF_Teachers_IsActive DEFAULT (1),
	CONSTRAINT FK_Teachers_Departments FOREIGN KEY (DepartmentId) REFERENCES dbo.Departments(DepartmentId)
);
GO

CREATE TABLE dbo.Students
(
	StudentId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Students PRIMARY KEY,
	StudentNumber varchar(20) NOT NULL CONSTRAINT UQ_Students_StudentNumber UNIQUE,
	FirstName nvarchar(50) NOT NULL,
	LastName nvarchar(50) NOT NULL,
	DateOfBirth date NOT NULL,
	Gender char(1) NULL,
	Email varchar(255) NULL CONSTRAINT UQ_Students_Email UNIQUE,
	Phone varchar(30) NULL,
	EnrollmentDate date NOT NULL,
	GraduationDate date NULL,
	Status varchar(20) NOT NULL CONSTRAINT DF_Students_Status DEFAULT ('Active'),
	StreetAddress nvarchar(200) NULL,
	City nvarchar(100) NULL,
	StateProvince nvarchar(100) NULL,
	PostalCode varchar(20) NULL,
	CONSTRAINT CK_Students_Gender CHECK (Gender IN ('F','M','X') OR Gender IS NULL),
	CONSTRAINT CK_Students_Status CHECK (Status IN ('Active','Inactive','Graduated','Withdrawn')),
	CONSTRAINT CK_Students_Dates CHECK (GraduationDate IS NULL OR GraduationDate >= EnrollmentDate)
);
GO

CREATE TABLE dbo.Guardians
(
	GuardianId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Guardians PRIMARY KEY,
	FirstName nvarchar(50) NOT NULL,
	LastName nvarchar(50) NOT NULL,
	Email varchar(255) NULL,
	Phone varchar(30) NOT NULL
);
GO

CREATE TABLE dbo.StudentGuardians
(
	StudentId int NOT NULL,
	GuardianId int NOT NULL,
	RelationshipType nvarchar(30) NOT NULL,
	IsPrimary bit NOT NULL CONSTRAINT DF_StudentGuardians_IsPrimary DEFAULT (0),
	CONSTRAINT PK_StudentGuardians PRIMARY KEY (StudentId, GuardianId),
	CONSTRAINT FK_StudentGuardians_Students FOREIGN KEY (StudentId) REFERENCES dbo.Students(StudentId),
	CONSTRAINT FK_StudentGuardians_Guardians FOREIGN KEY (GuardianId) REFERENCES dbo.Guardians(GuardianId)
);
GO

/* Curriculum and class scheduling */
CREATE TABLE dbo.Courses
(
	CourseId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Courses PRIMARY KEY,
	DepartmentId int NOT NULL,
	CourseCode varchar(20) NOT NULL CONSTRAINT UQ_Courses_Code UNIQUE,
	CourseName nvarchar(100) NOT NULL,
	Credits decimal(4,2) NOT NULL,
	Description nvarchar(500) NULL,
	CONSTRAINT FK_Courses_Departments FOREIGN KEY (DepartmentId) REFERENCES dbo.Departments(DepartmentId),
	CONSTRAINT CK_Courses_Credits CHECK (Credits > 0)
);
GO

CREATE TABLE dbo.CourseSections
(
	SectionId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_CourseSections PRIMARY KEY,
	CourseId int NOT NULL,
	TeacherId int NOT NULL,
	TermId int NOT NULL,
	RoomId int NULL,
	SectionCode varchar(20) NOT NULL,
	MeetingDays varchar(20) NOT NULL,
	StartTime time(0) NOT NULL,
	EndTime time(0) NOT NULL,
	MaxEnrollment int NOT NULL CONSTRAINT DF_CourseSections_MaxEnrollment DEFAULT (30),
	CONSTRAINT FK_CourseSections_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
	CONSTRAINT FK_CourseSections_Teachers FOREIGN KEY (TeacherId) REFERENCES dbo.Teachers(TeacherId),
	CONSTRAINT FK_CourseSections_Terms FOREIGN KEY (TermId) REFERENCES dbo.Terms(TermId),
	CONSTRAINT FK_CourseSections_Rooms FOREIGN KEY (RoomId) REFERENCES dbo.Rooms(RoomId),
	CONSTRAINT UQ_CourseSections_Code UNIQUE (CourseId, TermId, SectionCode),
	CONSTRAINT CK_CourseSections_Time CHECK (EndTime > StartTime),
	CONSTRAINT CK_CourseSections_MaxEnrollment CHECK (MaxEnrollment > 0)
);
GO

CREATE TABLE dbo.Enrollments
(
	EnrollmentId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Enrollments PRIMARY KEY,
	StudentId int NOT NULL,
	SectionId int NOT NULL,
	EnrollmentDate date NOT NULL CONSTRAINT DF_Enrollments_EnrollmentDate DEFAULT (CONVERT(date, GETDATE())),
	Status varchar(20) NOT NULL CONSTRAINT DF_Enrollments_Status DEFAULT ('Enrolled'),
	FinalGrade decimal(5,2) NULL,
	LetterGrade char(2) NULL,
	CONSTRAINT FK_Enrollments_Students FOREIGN KEY (StudentId) REFERENCES dbo.Students(StudentId),
	CONSTRAINT FK_Enrollments_Sections FOREIGN KEY (SectionId) REFERENCES dbo.CourseSections(SectionId),
	CONSTRAINT UQ_Enrollments_StudentSection UNIQUE (StudentId, SectionId),
	CONSTRAINT CK_Enrollments_Status CHECK (Status IN ('Enrolled','Completed','Dropped','Withdrawn')),
	CONSTRAINT CK_Enrollments_Grade CHECK (FinalGrade IS NULL OR FinalGrade BETWEEN 0 AND 100)
);
GO

/* Attendance, assessments, and assignments */
CREATE TABLE dbo.Attendance
(
	AttendanceId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Attendance PRIMARY KEY,
	EnrollmentId int NOT NULL,
	AttendanceDate date NOT NULL,
	AttendanceStatus varchar(20) NOT NULL,
	Notes nvarchar(250) NULL,
	CONSTRAINT FK_Attendance_Enrollments FOREIGN KEY (EnrollmentId) REFERENCES dbo.Enrollments(EnrollmentId),
	CONSTRAINT UQ_Attendance_EnrollmentDate UNIQUE (EnrollmentId, AttendanceDate),
	CONSTRAINT CK_Attendance_Status CHECK (AttendanceStatus IN ('Present','Absent','Late','Excused'))
);
GO

CREATE TABLE dbo.Assessments
(
	AssessmentId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Assessments PRIMARY KEY,
	SectionId int NOT NULL,
	AssessmentName nvarchar(100) NOT NULL,
	AssessmentType varchar(20) NOT NULL,
	DueDate date NOT NULL,
	MaxPoints decimal(8,2) NOT NULL,
	Weight decimal(5,2) NOT NULL,
	CONSTRAINT FK_Assessments_Sections FOREIGN KEY (SectionId) REFERENCES dbo.CourseSections(SectionId),
	CONSTRAINT CK_Assessments_Type CHECK (AssessmentType IN ('Quiz','Exam','Project','Homework','Participation')),
	CONSTRAINT CK_Assessments_Points CHECK (MaxPoints > 0 AND Weight BETWEEN 0 AND 100)
);
GO

CREATE TABLE dbo.AssessmentResults
(
	AssessmentResultId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_AssessmentResults PRIMARY KEY,
	AssessmentId int NOT NULL,
	EnrollmentId int NOT NULL,
	PointsEarned decimal(8,2) NOT NULL,
	Feedback nvarchar(1000) NULL,
	GradedDate date NULL,
	CONSTRAINT FK_AssessmentResults_Assessments FOREIGN KEY (AssessmentId) REFERENCES dbo.Assessments(AssessmentId),
	CONSTRAINT FK_AssessmentResults_Enrollments FOREIGN KEY (EnrollmentId) REFERENCES dbo.Enrollments(EnrollmentId),
	CONSTRAINT UQ_AssessmentResults_AssessmentEnrollment UNIQUE (AssessmentId, EnrollmentId),
	CONSTRAINT CK_AssessmentResults_Points CHECK (PointsEarned >= 0)
);
GO

/* Finance */
CREATE TABLE dbo.FeeTypes
(
	FeeTypeId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_FeeTypes PRIMARY KEY,
	FeeName nvarchar(100) NOT NULL CONSTRAINT UQ_FeeTypes_Name UNIQUE,
	DefaultAmount decimal(12,2) NOT NULL,
	CONSTRAINT CK_FeeTypes_Amount CHECK (DefaultAmount >= 0)
);
GO

CREATE TABLE dbo.StudentFees
(
	StudentFeeId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_StudentFees PRIMARY KEY,
	StudentId int NOT NULL,
	FeeTypeId int NOT NULL,
	TermId int NOT NULL,
	AmountDue decimal(12,2) NOT NULL,
	DueDate date NOT NULL,
	Status varchar(20) NOT NULL CONSTRAINT DF_StudentFees_Status DEFAULT ('Unpaid'),
	CONSTRAINT FK_StudentFees_Students FOREIGN KEY (StudentId) REFERENCES dbo.Students(StudentId),
	CONSTRAINT FK_StudentFees_FeeTypes FOREIGN KEY (FeeTypeId) REFERENCES dbo.FeeTypes(FeeTypeId),
	CONSTRAINT FK_StudentFees_Terms FOREIGN KEY (TermId) REFERENCES dbo.Terms(TermId),
	CONSTRAINT CK_StudentFees_Amount CHECK (AmountDue >= 0),
	CONSTRAINT CK_StudentFees_Status CHECK (Status IN ('Unpaid','PartiallyPaid','Paid','Waived'))
);
GO

CREATE TABLE dbo.Payments
(
	PaymentId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Payments PRIMARY KEY,
	StudentFeeId int NOT NULL,
	PaymentDate date NOT NULL CONSTRAINT DF_Payments_PaymentDate DEFAULT (CONVERT(date, GETDATE())),
	Amount decimal(12,2) NOT NULL,
	PaymentMethod varchar(20) NOT NULL,
	ReferenceNumber varchar(50) NULL CONSTRAINT UQ_Payments_Reference UNIQUE,
	CONSTRAINT FK_Payments_StudentFees FOREIGN KEY (StudentFeeId) REFERENCES dbo.StudentFees(StudentFeeId),
	CONSTRAINT CK_Payments_Amount CHECK (Amount > 0),
	CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('Cash','Card','Check','Transfer'))
);
GO

/* Library and transportation */
CREATE TABLE dbo.LibraryBooks
(
	BookId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_LibraryBooks PRIMARY KEY,
	ISBN varchar(20) NULL CONSTRAINT UQ_LibraryBooks_ISBN UNIQUE,
	Title nvarchar(200) NOT NULL,
	Author nvarchar(150) NOT NULL,
	Category nvarchar(100) NULL,
	CopiesAvailable int NOT NULL CONSTRAINT DF_LibraryBooks_CopiesAvailable DEFAULT (1),
	CONSTRAINT CK_LibraryBooks_Copies CHECK (CopiesAvailable >= 0)
);
GO

CREATE TABLE dbo.LibraryLoans
(
	LoanId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_LibraryLoans PRIMARY KEY,
	BookId int NOT NULL,
	StudentId int NOT NULL,
	LoanDate date NOT NULL CONSTRAINT DF_LibraryLoans_LoanDate DEFAULT (CONVERT(date, GETDATE())),
	DueDate date NOT NULL,
	ReturnDate date NULL,
	CONSTRAINT FK_LibraryLoans_Books FOREIGN KEY (BookId) REFERENCES dbo.LibraryBooks(BookId),
	CONSTRAINT FK_LibraryLoans_Students FOREIGN KEY (StudentId) REFERENCES dbo.Students(StudentId),
	CONSTRAINT CK_LibraryLoans_Dates CHECK (DueDate >= LoanDate AND (ReturnDate IS NULL OR ReturnDate >= LoanDate))
);
GO

CREATE TABLE dbo.TransportRoutes
(
	RouteId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_TransportRoutes PRIMARY KEY,
	RouteName nvarchar(100) NOT NULL CONSTRAINT UQ_TransportRoutes_Name UNIQUE,
	DriverName nvarchar(100) NOT NULL,
	VehicleNumber varchar(30) NOT NULL CONSTRAINT UQ_TransportRoutes_Vehicle UNIQUE,
	Capacity int NOT NULL,
	CONSTRAINT CK_TransportRoutes_Capacity CHECK (Capacity > 0)
);
GO

CREATE TABLE dbo.StudentTransport
(
	StudentId int NOT NULL,
	RouteId int NOT NULL,
	StartDate date NOT NULL,
	EndDate date NULL,
	PickupStop nvarchar(150) NOT NULL,
	CONSTRAINT PK_StudentTransport PRIMARY KEY (StudentId, RouteId, StartDate),
	CONSTRAINT FK_StudentTransport_Students FOREIGN KEY (StudentId) REFERENCES dbo.Students(StudentId),
	CONSTRAINT FK_StudentTransport_Routes FOREIGN KEY (RouteId) REFERENCES dbo.TransportRoutes(RouteId),
	CONSTRAINT CK_StudentTransport_Dates CHECK (EndDate IS NULL OR EndDate >= StartDate)
);
GO

/* Useful indexes */
CREATE INDEX IX_Students_LastName_FirstName ON dbo.Students (LastName, FirstName);
CREATE INDEX IX_Enrollments_SectionId ON dbo.Enrollments (SectionId);
CREATE INDEX IX_Attendance_Date_Status ON dbo.Attendance (AttendanceDate, AttendanceStatus);
CREATE INDEX IX_AssessmentResults_EnrollmentId ON dbo.AssessmentResults (EnrollmentId);
CREATE INDEX IX_StudentFees_StudentId_Status ON dbo.StudentFees (StudentId, Status);
CREATE INDEX IX_LibraryLoans_StudentId_ReturnDate ON dbo.LibraryLoans (StudentId, ReturnDate);
GO

/* Seed data */
INSERT dbo.AcademicYears (YearName, StartDate, EndDate, IsCurrent)
VALUES ('2025-2026', '2025-08-25', '2026-06-12', 1);

INSERT dbo.Terms (AcademicYearId, TermName, StartDate, EndDate)
VALUES
	(1, 'Fall', '2025-08-25', '2025-12-19'),
	(1, 'Spring', '2026-01-05', '2026-06-12');

INSERT dbo.Departments (DepartmentName, Description)
VALUES
	('Mathematics', 'Mathematics and statistics'),
	('Science', 'Natural sciences'),
	('English', 'Language arts and literature'),
	('Technology', 'Computer science and information technology');

INSERT dbo.Buildings (BuildingName) VALUES ('Main Building'), ('Science Center');
INSERT dbo.Rooms (BuildingId, RoomNumber, Capacity) VALUES (1, '101', 30), (1, '202', 28), (2, 'Lab-1', 24);

INSERT dbo.Teachers (DepartmentId, EmployeeNumber, FirstName, LastName, Email, Phone, HireDate)
VALUES
	(1, 'T1001', 'Maria', 'Chen', 'maria.chen@schooldemo.edu', '555-0101', '2020-08-15'),
	(2, 'T1002', 'James', 'Rivera', 'james.rivera@schooldemo.edu', '555-0102', '2019-08-15'),
	(4, 'T1003', 'Avery', 'Patel', 'avery.patel@schooldemo.edu', '555-0103', '2022-08-15');

INSERT dbo.Students (StudentNumber, FirstName, LastName, DateOfBirth, Gender, Email, Phone, EnrollmentDate, StreetAddress, City, StateProvince, PostalCode)
VALUES
	('S10001', 'Olivia', 'Martin', '2010-03-14', 'F', 'olivia.martin@student.schooldemo.edu', '555-1001', '2024-08-26', '10 Oak Street', 'Springfield', 'IL', '62701'),
	('S10002', 'Noah', 'Williams', '2009-11-02', 'M', 'noah.williams@student.schooldemo.edu', '555-1002', '2024-08-26', '22 Pine Avenue', 'Springfield', 'IL', '62702'),
	('S10003', 'Sophia', 'Garcia', '2010-07-28', 'F', 'sophia.garcia@student.schooldemo.edu', '555-1003', '2025-08-25', '8 Lake Road', 'Springfield', 'IL', '62703');

INSERT dbo.Guardians (FirstName, LastName, Email, Phone)
VALUES ('Daniel', 'Martin', 'daniel.martin@example.com', '555-2001'), ('Emma', 'Williams', 'emma.williams@example.com', '555-2002');
INSERT dbo.StudentGuardians (StudentId, GuardianId, RelationshipType, IsPrimary)
VALUES (1, 1, 'Parent', 1), (2, 2, 'Parent', 1), (3, 1, 'Guardian', 0);

INSERT dbo.Courses (DepartmentId, CourseCode, CourseName, Credits, Description)
VALUES
	(1, 'MATH101', 'Algebra I', 1.00, 'Foundations of algebra and equations'),
	(2, 'SCI101', 'General Science', 1.00, 'Introduction to scientific methods'),
	(4, 'CS101', 'Introduction to Programming', 1.00, 'Programming fundamentals and problem solving');

INSERT dbo.CourseSections (CourseId, TeacherId, TermId, RoomId, SectionCode, MeetingDays, StartTime, EndTime, MaxEnrollment)
VALUES
	(1, 1, 1, 1, 'A', 'Mon/Wed', '09:00', '10:00', 30),
	(2, 2, 1, 3, 'A', 'Tue/Thu', '10:00', '11:00', 24),
	(3, 3, 1, 2, 'A', 'Mon/Wed', '11:00', '12:00', 28);

INSERT dbo.Enrollments (StudentId, SectionId, EnrollmentDate, Status, FinalGrade, LetterGrade)
VALUES (1, 1, '2025-08-25', 'Enrolled', NULL, NULL), (1, 2, '2025-08-25', 'Enrolled', NULL, NULL),
	   (2, 1, '2025-08-25', 'Enrolled', NULL, NULL), (2, 3, '2025-08-25', 'Enrolled', NULL, NULL),
	   (3, 2, '2025-08-25', 'Enrolled', NULL, NULL), (3, 3, '2025-08-25', 'Enrolled', NULL, NULL);

INSERT dbo.Attendance (EnrollmentId, AttendanceDate, AttendanceStatus, Notes)
VALUES (1, '2025-09-02', 'Present', NULL), (2, '2025-09-02', 'Late', 'Arrived five minutes late'),
	   (3, '2025-09-02', 'Present', NULL), (4, '2025-09-02', 'Absent', 'Parent notified');

INSERT dbo.Assessments (SectionId, AssessmentName, AssessmentType, DueDate, MaxPoints, Weight)
VALUES (1, 'Unit 1 Test', 'Exam', '2025-09-26', 100, 25),
	   (2, 'Lab Safety Quiz', 'Quiz', '2025-09-12', 20, 10),
	   (3, 'First Program', 'Project', '2025-10-03', 100, 30);
INSERT dbo.AssessmentResults (AssessmentId, EnrollmentId, PointsEarned, Feedback, GradedDate)
VALUES (1, 1, 92, 'Strong work', '2025-09-29'), (1, 3, 84, 'Review linear equations', '2025-09-29'),
	   (2, 2, 18, 'Good understanding', '2025-09-15');

INSERT dbo.FeeTypes (FeeName, DefaultAmount) VALUES ('Tuition', 500.00), ('Technology Fee', 75.00), ('Library Fee', 25.00);
INSERT dbo.StudentFees (StudentId, FeeTypeId, TermId, AmountDue, DueDate, Status)
VALUES (1, 1, 1, 500.00, '2025-09-15', 'Paid'), (1, 2, 1, 75.00, '2025-09-15', 'Unpaid'),
	   (2, 1, 1, 500.00, '2025-09-15', 'PartiallyPaid');
INSERT dbo.Payments (StudentFeeId, PaymentDate, Amount, PaymentMethod, ReferenceNumber)
VALUES (1, '2025-09-10', 500.00, 'Card', 'PAY-10001'), (3, '2025-09-10', 250.00, 'Transfer', 'PAY-10002');

INSERT dbo.LibraryBooks (ISBN, Title, Author, Category, CopiesAvailable)
VALUES ('9780131103627', 'The C Programming Language', 'Brian Kernighan', 'Programming', 2),
	   ('9780262033848', 'Introduction to Algorithms', 'Thomas Cormen', 'Computer Science', 1),
	   ('9780743273565', 'The Great Gatsby', 'F. Scott Fitzgerald', 'Literature', 3);
INSERT dbo.LibraryLoans (BookId, StudentId, LoanDate, DueDate)
VALUES (1, 1, '2025-09-01', '2025-09-15');

INSERT dbo.TransportRoutes (RouteName, DriverName, VehicleNumber, Capacity)
VALUES ('North Route', 'Taylor Brooks', 'BUS-01', 40), ('South Route', 'Jordan Lee', 'BUS-02', 35);
INSERT dbo.StudentTransport (StudentId, RouteId, StartDate, PickupStop)
VALUES (1, 1, '2025-08-25', 'Oak Street and First Avenue'), (2, 2, '2025-08-25', 'Pine Avenue and Third Street');
GO

/* Reporting views */
CREATE VIEW dbo.vw_StudentDirectory
AS
SELECT s.StudentId, s.StudentNumber, s.FirstName, s.LastName, s.Status,
	   s.Email, s.Phone, g.FirstName + N' ' + g.LastName AS PrimaryGuardian,
	   g.Phone AS GuardianPhone
FROM dbo.Students AS s
LEFT JOIN dbo.StudentGuardians AS sg ON sg.StudentId = s.StudentId AND sg.IsPrimary = 1
LEFT JOIN dbo.Guardians AS g ON g.GuardianId = sg.GuardianId;
GO

CREATE VIEW dbo.vw_ClassRoster
AS
SELECT cs.SectionId, c.CourseCode, c.CourseName, cs.SectionCode,
	   t.FirstName + N' ' + t.LastName AS Teacher,
	   s.StudentNumber, s.FirstName + N' ' + s.LastName AS StudentName,
	   e.Status, e.FinalGrade, e.LetterGrade
FROM dbo.Enrollments AS e
JOIN dbo.Students AS s ON s.StudentId = e.StudentId
JOIN dbo.CourseSections AS cs ON cs.SectionId = e.SectionId
JOIN dbo.Courses AS c ON c.CourseId = cs.CourseId
JOIN dbo.Teachers AS t ON t.TeacherId = cs.TeacherId;
GO

CREATE VIEW dbo.vw_StudentAccountBalances
AS
SELECT s.StudentId, s.StudentNumber, s.FirstName + N' ' + s.LastName AS StudentName,
	   COALESCE(SUM(sf.AmountDue), 0.00) AS TotalDue,
	   COALESCE(SUM(p.Amount), 0.00) AS TotalPaid,
	   COALESCE(SUM(sf.AmountDue), 0.00) - COALESCE(SUM(p.Amount), 0.00) AS Balance
FROM dbo.Students AS s
LEFT JOIN dbo.StudentFees AS sf ON sf.StudentId = s.StudentId
LEFT JOIN dbo.Payments AS p ON p.StudentFeeId = sf.StudentFeeId
GROUP BY s.StudentId, s.StudentNumber, s.FirstName, s.LastName;
GO

/* Example read-only reporting procedure */
CREATE PROCEDURE dbo.usp_GetStudentReport
	@StudentId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM dbo.vw_StudentDirectory
	WHERE StudentId = @StudentId;

	SELECT *
	FROM dbo.vw_ClassRoster
	WHERE StudentNumber = (SELECT StudentNumber FROM dbo.Students WHERE StudentId = @StudentId);

	SELECT *
	FROM dbo.vw_StudentAccountBalances
	WHERE StudentId = @StudentId;
END;
GO

/* Verification queries: these are read-only and safe to execute after setup. */
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

SELECT * FROM dbo.vw_StudentDirectory;
SELECT * FROM dbo.vw_ClassRoster ORDER BY CourseCode, StudentName;
SELECT * FROM dbo.vw_StudentAccountBalances;
GO

