-- Tạo database
CREATE DATABASE GiuaKy
ON PRIMARY
    -- File chính trong Primary Filegroup (C:)
    (NAME = N'GiuaKy_Primary',
     FILENAME = N'C:\SQLData\GiuaKy_Primary.mdf',
     SIZE = 10240KB, -- 10MB
     FILEGROWTH = 1024KB), -- 1MB
FILEGROUP CustomerDataFG
    -- File trong CustomerDataFG (D:)
    (NAME = N'GiuaKy_CustomerData',
     FILENAME = N'D:\SQLData\GiuaKy_CustomerData.ndf',
     SIZE = 10240KB,
     FILEGROWTH = 1024KB),
FILEGROUP GoodsDataFG
    -- File 1 trong GoodsDataFG (C:)
    (NAME = N'GiuaKy_GoodsData',
     FILENAME = N'C:\SQLData\GiuaKy_GoodsData.ndf',
     SIZE = 10240KB,
     FILEGROWTH = 1024KB),
    -- File 2 trong GoodsDataFG (C:)
    (NAME = N'GiuaKy_GoodsData2',
     FILENAME = N'C:\SQLData\GiuaKy_GoodsData2.ndf',
     SIZE = 10240KB,
     FILEGROWTH = 1024KB),
FILEGROUP DeclarationFG
    -- File trong DeclarationFG (D:)
    (NAME = N'GiuaKy_Declaration',
     FILENAME = N'D:\SQLData\GiuaKy_Declaration.ndf',
     SIZE = 10240KB,
     FILEGROWTH = 1024KB),
FILEGROUP DocumentFG
    -- File trong DocumentFG (E:)
    (NAME = N'GiuaKy_Document',
     FILENAME = N'E:\SQLData\GiuaKy_Document.ndf',
     SIZE = 10240KB,
     FILEGROWTH = 1024KB),
FILEGROUP PaymentFG
    -- File trong PaymentFG (C:)
    (NAME = N'GiuaKy_Payment',
     FILENAME = N'C:\SQLData\GiuaKy_Payment.ndf',
     SIZE = 10240KB,
     FILEGROWTH = 1024KB)
LOG ON
    -- File log (E:)
    (NAME = N'GiuaKy_Log',
     FILENAME = N'E:\SQLLog\GiuaKy_Log.ldf',
     SIZE = 5120KB, -- 5MB
     FILEGROWTH = 1024KB);
GO

-- Sử dụng database
USE GiuaKy;
GO

-- Tạo các bảng trên các filegroup tương ứng

-- Primary Filegroup (C:): Department, Employee
CREATE TABLE Department (
    Department_ID VARCHAR(4) PRIMARY KEY NOT NULL,
    Department_Name NVARCHAR(30) NOT NULL,
    Manager_ID VARCHAR(10)
) ON [PRIMARY];

CREATE TABLE Employee (
    Employee_ID VARCHAR(10) PRIMARY KEY NOT NULL,
    Department_ID VARCHAR(4) NOT NULL,
    Employee_Name NVARCHAR(50) NOT NULL,
    Employee_Phone CHAR(10) NOT NULL,
    Employee_Email VARCHAR(50) NOT NULL,
    Hired_Date DATE NOT NULL,
    Salary INT NOT NULL,
    Role NVARCHAR(30) NOT NULL,
    Manager_ID VARCHAR(10)
) ON [PRIMARY];

-- CustomerDataFG (D:): Customer, Service_Request, Consultation
CREATE TABLE Customer (
    Customer_ID VARCHAR(10) PRIMARY KEY NOT NULL,
    Customer_Name NVARCHAR(50) NOT NULL,
    Customer_Email VARCHAR(50) NOT NULL,
    Customer_Phone CHAR(10) NOT NULL,
    Bank_Account_Number NUMERIC(15, 0) NOT NULL,
    Tax_Code CHAR(10) NOT NULL CHECK (LEN(Tax_Code) = 10),
    Company_Name NVARCHAR(50),
    Address NVARCHAR(100) NOT NULL
) ON [CustomerDataFG];

CREATE TABLE Service_Request (
    Request_ID NUMERIC(6) PRIMARY KEY NOT NULL,
    Customer_ID VARCHAR(10) NOT NULL,
    Service_Type NVARCHAR(20) NOT NULL,
    Service_Charges NUMERIC(14) NOT NULL,
    Request_Date DATE NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Pending', 'Processing', 'Completed', 'Rejected', 'Cancelled')),
    Employee_ID VARCHAR(10) NOT NULL
) ON [CustomerDataFG];

CREATE TABLE Consultation (
    Consultant_ID INT PRIMARY KEY NOT NULL,
    Customer_ID VARCHAR(10) NOT NULL,
    Employee_ID VARCHAR(10) NOT NULL,
    Consultant_Date DATE NOT NULL,
    Goods_Type VARCHAR(50) CHECK (Goods_Type IN ('General Goods', 'Hazardous', 'Perishable')),
    Estimate_HS_Code NUMERIC(14, 0) NOT NULL,
    Estimate_Tax_Rate NUMERIC(14, 2) NOT NULL,
    Estimate_Cost NUMERIC(14, 0) NOT NULL,
    Required_Permit NVARCHAR(50) NOT NULL,
    Status NVARCHAR(50) CHECK (Status IN ('Pending', 'Processing', 'Completed', 'Rejected', 'Cancelled')) NOT NULL,
    Notes TEXT
) ON [CustomerDataFG];

-- GoodsDataFG (C:): Goods, Goods_Detail, Perishable_Goods, Hazardous_Goods, General_Goods
CREATE TABLE Goods (
    Goods_ID VARCHAR(6) PRIMARY KEY NOT NULL,
    Goods_Name NVARCHAR(100) NOT NULL,
    Unit_Price NUMERIC(14, 0) NOT NULL,
    HS_Code CHAR(8) NOT NULL,
    Goods_Type CHAR(1) CHECK (Goods_Type IN ('G', 'H', 'P'))
) ON [GoodsDataFG];

CREATE TABLE Goods_Detail (
    Detail_ID VARCHAR(10) PRIMARY KEY NOT NULL,
    Declaration_ID CHAR(12) NOT NULL,
    Goods_ID VARCHAR(6) NOT NULL,
    Quantity INT NOT NULL,
    Net_Weight NUMERIC(10, 0) NOT NULL,
    Gross_Weight NUMERIC(10, 0) NOT NULL,
    Total_Value NUMERIC(14, 0) NOT NULL
) ON [GoodsDataFG];

CREATE TABLE Perishable_Goods (
    Perishable_Goods_ID VARCHAR(6) PRIMARY KEY,
    Exp_Date DATE,
    Temperature VARCHAR(10),
    Humidity VARCHAR(4)
) ON [GoodsDataFG];

CREATE TABLE Hazardous_Goods (
    Hazardous_Goods_ID VARCHAR(6) PRIMARY KEY,
    Hazard_Level VARCHAR(6),
    Safety_Instructions NVARCHAR(50)
) ON [GoodsDataFG];

CREATE TABLE General_Goods (
    General_Goods_ID VARCHAR(6) PRIMARY KEY
) ON [GoodsDataFG];

-- DeclarationFG (D:): Customer_Declaration, Goods_Inspection, Post_Clearance_Service
CREATE TABLE Customer_Declaration (
    Declaration_ID CHAR(12) PRIMARY KEY NOT NULL,
    Contract_ID VARCHAR(10) NOT NULL,
    Employee_ID VARCHAR(10) NOT NULL,
    Declaration_Type NVARCHAR(50) NOT NULL,
    VNACCS_ID VARCHAR(15) NOT NULL,
    Inspection_Channel VARCHAR(6) NOT NULL,
    Status VARCHAR(50) CHECK (Status IN ('Pending', 'Processing', 'Completed', 'Rejected', 'Cancelled')),
    Submission_Date DATE
) ON [DeclarationFG];

CREATE TABLE Goods_Inspection (
    Inspection_ID VARCHAR(10) PRIMARY KEY NOT NULL,
    Declaration_ID CHAR(12) NOT NULL,
    Employee_ID VARCHAR(10) NOT NULL,
    Inspection_Type NVARCHAR(50) CHECK (Inspection_Type IN ('Physical', 'Document', 'X-ray', 'Sample Testing')),
    Schedule_Date DATE NOT NULL,
    Inspection_Location NVARCHAR(100) NOT NULL,
    Status NVARCHAR(50) CHECK (Status IN ('Pending', 'Processing', 'Completed', 'Rejected', 'Cancelled')),
    Inspector_Name NVARCHAR(50) NOT NULL,
    Result NVARCHAR(50) NOT NULL,
    Notes TEXT
) ON [DeclarationFG];

CREATE TABLE Post_Clearance_Service (
    Post_Clearance_Service_ID NUMERIC(6) PRIMARY KEY NOT NULL,
    Declaration_ID CHAR(12) NOT NULL,
    Document_Storage_Ref VARCHAR(30) NOT NULL,
    Consultant_Notes TEXT,
    Review_Date DATE NOT NULL,
    Report NVARCHAR(50) NOT NULL,
    Improvement_Suggestion TEXT NOT NULL,
    Status NVARCHAR(50) CHECK (Status IN ('Pending', 'Processing', 'Completed', 'Rejected', 'Cancelled'))
) ON [DeclarationFG];

-- DocumentFG (E:): Contract, Document_Set, Document
CREATE TABLE Contract (
    Contract_ID VARCHAR(10) PRIMARY KEY,
    Request_ID NUMERIC(6),
    Contract_Date DATE,
    Total_Value NUMERIC(14),
    Payment_Term NVARCHAR(15),
    Status NVARCHAR(50) CHECK (Status IN ('Pending', 'Processing', 'Completed', 'Rejected', 'Cancelled'))
) ON [DocumentFG];

CREATE TABLE Document_Set (
    Document_Set_ID NUMERIC(8) PRIMARY KEY,
    Contract_ID VARCHAR(10),
    Declaration_ID CHAR(12),
    Verification_Status NVARCHAR(20),
    Notes TEXT,
    Status NVARCHAR(50) CHECK (Status IN ('Pending', 'Processing', 'Completed', 'Rejected', 'Cancelled'))
) ON [DocumentFG];

CREATE TABLE Document (
    Document_ID NUMERIC(8) PRIMARY KEY,
    Commercial_Invoice VARBINARY(MAX),
    Packing_List VARBINARY(MAX),
    Bill_Of_Lading VARBINARY(MAX),
    C_O VARBINARY(MAX),
    Import_Permit VARBINARY(MAX),
    Other_Certification VARBINARY(MAX),
    Document_Set_ID NUMERIC(8)
) ON [DocumentFG];

-- PaymentFG (C:): Payment
CREATE TABLE Payment (
    Payment_ID VARCHAR(15) PRIMARY KEY,
    Contract_ID VARCHAR(10),
    Tax_Fee NUMERIC(10),
    Amount INT,
    Payment_Date DATE
) ON [PaymentFG];

-- Thêm các ràng buộc khóa ngoại
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID),
    CONSTRAINT FK_Employee_Manager FOREIGN KEY (Manager_ID) REFERENCES Employee(Employee_ID);

ALTER TABLE Department
ADD CONSTRAINT FK_Department_Manager FOREIGN KEY (Manager_ID) REFERENCES Employee(Employee_ID);

ALTER TABLE Goods_Detail
ADD CONSTRAINT FK_GoodsDetail_Declaration FOREIGN KEY (Declaration_ID) REFERENCES Customer_Declaration(Declaration_ID),
    CONSTRAINT FK_GoodsDetail_Goods FOREIGN KEY (Goods_ID) REFERENCES Goods(Goods_ID);

ALTER TABLE Perishable_Goods
ADD CONSTRAINT FK_PerishableGoods_Goods FOREIGN KEY (Perishable_Goods_ID) REFERENCES Goods(Goods_ID);

ALTER TABLE Hazardous_Goods
ADD CONSTRAINT FK_HazardousGoods_Goods FOREIGN KEY (Hazardous_Goods_ID) REFERENCES Goods(Goods_ID);

ALTER TABLE General_Goods
ADD CONSTRAINT FK_GeneralGoods_Goods FOREIGN KEY (General_Goods_ID) REFERENCES Goods(Goods_ID);

ALTER TABLE Consultation
ADD CONSTRAINT FK_Consultation_Customer FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    CONSTRAINT FK_Consultation_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID);

ALTER TABLE Service_Request
ADD CONSTRAINT FK_ServiceRequest_Customer FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    CONSTRAINT FK_ServiceRequest_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID);

ALTER TABLE Goods_Inspection
ADD CONSTRAINT FK_GoodsInspection_Declaration FOREIGN KEY (Declaration_ID) REFERENCES Customer_Declaration(Declaration_ID),
    CONSTRAINT FK_GoodsInspection_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID);

ALTER TABLE Post_Clearance_Service
ADD CONSTRAINT FK_PostClearanceService_Declaration FOREIGN KEY (Declaration_ID) REFERENCES Customer_Declaration(Declaration_ID);

ALTER TABLE Customer_Declaration
ADD CONSTRAINT FK_CustomerDeclaration_Contract FOREIGN KEY (Contract_ID) REFERENCES Contract(Contract_ID),
    CONSTRAINT FK_CustomerDeclaration_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID);

ALTER TABLE Contract
ADD CONSTRAINT FK_Contract_ServiceRequest FOREIGN KEY (Request_ID) REFERENCES Service_Request(Request_ID);

ALTER TABLE Document_Set
ADD CONSTRAINT FK_DocumentSet_Contract FOREIGN KEY (Contract_ID) REFERENCES Contract(Contract_ID),
    CONSTRAINT FK_DocumentSet_Declaration FOREIGN KEY (Declaration_ID) REFERENCES Customer_Declaration(Declaration_ID);

ALTER TABLE Document
ADD CONSTRAINT FK_Document_DocumentSet FOREIGN KEY (Document_Set_ID) REFERENCES Document_Set(Document_Set_ID);

ALTER TABLE Payment
ADD CONSTRAINT FK_Payment_Contract FOREIGN KEY (Contract_ID) REFERENCES Contract(Contract_ID);

-- Chèn dữ liệu (DML)
-- Insert Department data
INSERT INTO Department (Department_ID, Department_Name, Manager_ID) VALUES
('D001', N'Tư vấn khách hàng', NULL),
('D002', N'Khai báo hải quan', NULL),
('D003', N'Kiểm tra hàng hóa', NULL),
('D004', N'Kế toán', NULL),
('D005', N'Nhân sự', NULL),
('D006', N'CNTT', NULL),
('D007', N'Marketing', NULL),
('D008', N'Dịch vụ sau thông quan', NULL),
('D009', N'Quản lý rủi ro', NULL),
('D010', N'Quản lý chất lượng', NULL),
('D011', N'Quan hệ khách hàng', NULL),
('D012', N'Pháp chế', NULL);

-- Insert Employee data
INSERT INTO Employee (Employee_ID, Department_ID, Employee_Name, Employee_Phone, Employee_Email, Hired_Date, Salary, Role, Manager_ID) VALUES
('E001', 'D001', N'Nguyễn Văn An', '0901234567', 'an.nguyen@company.com', '2020-01-15', 15000000, N'Trưởng phòng', NULL),
('E002', 'D002', N'Trần Thị Bình', '0912345678', 'binh.tran@company.com', '2020-02-20', 14000000, N'Trưởng phòng', NULL),
('E003', 'D003', N'Lê Văn Cường', '0923456789', 'cuong.le@company.com', '2020-03-10', 13000000, N'Trưởng phòng', NULL),
('E004', 'D004', N'Phạm Thị Dung', '0934567890', 'dung.pham@company.com', '2020-04-05', 12000000, N'Nhân viên', 'E001'),
('E005', 'D005', N'Hoàng Văn Em', '0945678901', 'em.hoang@company.com', '2020-05-15', 11000000, N'Nhân viên', 'E001'),
('E006', 'D006', N'Đỗ Thị Phương', '0956789012', 'phuong.do@company.com', '2020-06-20', 10000000, N'Nhân viên', 'E002'),
('E007', 'D007', N'Vũ Văn Giang', '0967890123', 'giang.vu@company.com', '2020-07-10', 12000000, N'Nhân viên', 'E002'),
('E008', 'D008', N'Mai Thị Hương', '0978901234', 'huong.mai@company.com', '2020-08-15', 11000000, N'Nhân viên', 'E003'),
('E009', 'D009', N'Bùi Văn Inh', '0989012345', 'inh.bui@company.com', '2020-09-20', 10000000, N'Nhân viên', 'E003'),
('E010', 'D010', N'Lý Thị Kim', '0990123456', 'kim.ly@company.com', '2020-10-10', 12000000, N'Nhân viên', 'E001'),
('E011', 'D011', N'Trương Văn Linh', '0901234567', 'linh.truong@company.com', '2020-11-15', 11000000, N'Nhân viên', 'E002'),
('E012', 'D012', N'Ngô Thị Minh', '0912345678', 'minh.ngo@company.com', '2020-12-20', 10000000, N'Nhân viên', 'E003');

-- Update Manager_ID for Department
UPDATE Department SET Manager_ID = 'E001' WHERE Department_ID = 'D001';
UPDATE Department SET Manager_ID = 'E002' WHERE Department_ID = 'D002';
UPDATE Department SET Manager_ID = 'E003' WHERE Department_ID = 'D003';

-- Insert Customer data
INSERT INTO Customer (Customer_ID, Customer_Name, Customer_Email, Customer_Phone, Bank_Account_Number, Tax_Code, Company_Name, Address) VALUES
('C001', N'Công ty TNHH A', 'contact@companya.com', '0901234567', 123456789012345, '0123456789', N'Công ty TNHH A', N'123 Nguyễn Huệ, Q1, TP.HCM'),
('C002', N'Công ty CP B', 'contact@companyb.com', '0912345678', 234567890123456, '1234567890', N'Công ty CP B', N'456 Lê Lợi, Q1, TP.HCM'),
('C003', N'Công ty TNHH C', 'contact@companyc.com', '0923456789', 345678901234567, '2345678901', N'Công ty TNHH C', N'789 Trần Hưng Đạo, Q5, TP.HCM'),
('C004', N'Công ty CP D', 'contact@companyd.com', '0934567890', 456789012345678, '3456789012', N'Công ty CP D', N'321 Hai Bà Trưng, Q3, TP.HCM'),
('C005', N'Công ty TNHH E', 'contact@companye.com', '0945678901', 567890123456789, '4567890123', N'Công ty TNHH E', N'654 Nguyễn Trãi, Q5, TP.HCM'),
('C006', N'Công ty CP F', 'contact@companyf.com', '0956789012', 678901234567890, '5678901234', N'Công ty CP F', N'987 Cách Mạng Tháng 8, Q3, TP.HCM'),
('C007', N'Công ty TNHH G', 'contact@companyg.com', '0967890123', 789012345678901, '6789012345', N'Công ty TNHH G', N'147 Võ Văn Tần, Q3, TP.HCM'),
('C008', N'Công ty CP H', 'contact@companyh.com', '0978901234', 890123456789012, '7890123456', N'Công ty CP H', N'258 Nam Kỳ Khởi Nghĩa, Q3, TP.HCM'),
('C009', N'Công ty TNHH I', 'contact@companyi.com', '0989012345', 901234567890123, '8901234567', N'Công ty TNHH I', N'369 Lý Tự Trọng, Q1, TP.HCM'),
('C010', N'Công ty CP J', 'contact@companyj.com', '0990123456', 012345678901234, '9012345678', N'Công ty CP J', N'159 Pasteur, Q1, TP.HCM'),
('C011', N'Công ty TNHH K', 'contact@companyk.com', '0901234567', 123456789012346, '0123456780', N'Công ty TNHH K', N'753 Điện Biên Phủ, Bình Thạnh, TP.HCM'),
('C012', N'Công ty CP L', 'contact@companyl.com', '0912345678', 234567890123457, '1234567891', N'Công ty CP L', N'951 Nguyễn Đình Chiểu, Q3, TP.HCM');

-- Insert Goods data
INSERT INTO Goods (Goods_ID, Goods_Name, Unit_Price, HS_Code, Goods_Type) VALUES
('G00001', N'Máy tính xách tay', 15000000, '84713010', 'G'),
('G00002', N'Điện thoại di động', 10000000, '85171200', 'G'),
('H00001', N'Axit sulfuric', 5000000, '28070010', 'H'),
('H00002', N'Dung môi công nghiệp', 3000000, '38140000', 'H'),
('P00001', N'Sữa tươi', 50000, '04012000', 'P'),
('P00002', N'Thịt bò đông lạnh', 200000, '02023000', 'P'),
('G00003', N'Máy in laser', 8000000, '84433100', 'G'),
('H00003', N'Sơn công nghiệp', 1000000, '32089090', 'H'),
('P00003', N'Hải sản đông lạnh', 150000, '03061700', 'P'),
('G00004', N'Thiết bị mạng', 5000000, '84713020', 'G'),
('H00004', N'Hóa chất tẩy rửa', 80000, '34022090', 'H'),
('P00004', N'Rau củ đông lạnh', 100000, '07108000', 'P');

-- Insert specialized goods data
INSERT INTO General_Goods (General_Goods_ID) VALUES
('G00001'), ('G00002'), ('G00003'), ('G00004');

INSERT INTO Hazardous_Goods (Hazardous_Goods_ID, Hazard_Level, Safety_Instructions) VALUES
('H00001', 'High', N'Bảo quản nơi khô ráo, tránh va đập'),
('H00002', 'Medium', N'Tránh tiếp xúc trực tiếp, đeo găng tay bảo hộ'),
('H00003', 'Medium', N'Bảo quản nơi thoáng mát, tránh nguồn lửa'),
('H00004', 'Low', N'Đeo găng tay và khẩu trang khi sử dụng');

INSERT INTO Perishable_Goods (Perishable_Goods_ID, Exp_Date, Temperature, Humidity) VALUES
('P00001', '2024-12-31', '4°C', '60%'),
('P00002', '2024-12-31', '-18°C', '70%'),
('P00003', '2024-12-31', '-20°C', '75%'),
('P00004', '2024-12-31', '-15°C', '65%');

-- Insert Service_Request data
INSERT INTO Service_Request (Request_ID, Customer_ID, Service_Type, Service_Charges, Request_Date, Status, Employee_ID) VALUES
(100001, 'C001', N'Khai báo hải quan', 5000000, '2024-01-15', 'Completed', 'E001'),
(100002, 'C002', N'Tư vấn', 3000000, '2024-01-20', 'Completed', 'E002'),
(100003, 'C003', N'Kiểm tra hàng', 4000000, '2024-01-25', 'Processing', 'E003'),
(100004, 'C004', N'Khai báo hải quan', 5000000, '2024-02-01', 'Pending', 'E004'),
(100005, 'C005', N'Tư vấn', 3000000, '2024-02-05', 'Completed', 'E005'),
(100006, 'C006', N'Kiểm tra hàng', 4000000, '2024-02-10', 'Processing', 'E006'),
(100007, 'C007', N'Khai báo hải quan', 5000000, '2024-02-15', 'Completed', 'E007'),
(100008, 'C008', N'Tư vấn', 3000000, '2024-02-20', 'Pending', 'E008'),
(100009, 'C009', N'Kiểm tra hàng', 4000000, '2024-02-25', 'Processing', 'E009'),
(100010, 'C010', N'Khai báo hải quan', 5000000, '2024-03-01', 'Completed', 'E010'),
(100011, 'C011', N'Tư vấn', 3000000, '2024-03-05', 'Pending', 'E011'),
(100012, 'C012', N'Kiểm tra hàng', 4000000, '2024-03-10', 'Processing', 'E012');

-- Insert Contract data
INSERT INTO Contract (Contract_ID, Request_ID, Contract_Date, Total_Value, Payment_Term, Status) VALUES
('CT001', 100001, '2024-01-16', 50000000, N'30 ngày', 'Completed'),
('CT002', 100002, '2024-01-21', 30000000, N'15 ngày', 'Completed'),
('CT003', 100003, '2024-01-26', 40000000, N'30 ngày', 'Processing'),
('CT004', 100004, '2024-02-02', 55000000, N'45 ngày', 'Pending'),
('CT005', 100005, '2024-02-06', 35000000, N'30 ngày', 'Completed'),
('CT006', 100006, '2024-02-11', 45000000, N'30 ngày', 'Processing'),
('CT007', 100007, '2024-02-16', 52000000, N'45 ngày', 'Completed'),
('CT008', 100008, '2024-02-21', 33000000, N'15 ngày', 'Pending'),
('CT009', 100009, '2024-02-26', 42000000, N'30 ngày', 'Processing'),
('CT010', 100010, '2024-03-02', 51000000, N'45 ngày', 'Completed'),
('CT011', 100011, '2024-03-06', 31000000, N'15 ngày', 'Pending'),
('CT012', 100012, '2024-03-11', 43000000, N'30 ngày', 'Processing');

-- Insert Customer_Declaration data
INSERT INTO Customer_Declaration (Declaration_ID, Contract_ID, Employee_ID, Declaration_Type, VNACCS_ID, Inspection_Channel, Status, Submission_Date) VALUES
('D202401001', 'CT001', 'E001', N'Nhập khẩu', 'VNA001', 'GREEN', 'Completed', '2024-01-17'),
('D202401002', 'CT002', 'E002', N'Xuất khẩu', 'VNA002', 'RED', 'Completed', '2024-01-22'),
('D202401003', 'CT003', 'E003', N'Nhập khẩu', 'VNA003', 'YELLOW', 'Processing', '2024-01-27'),
('D202402001', 'CT004', 'E004', N'Xuất khẩu', 'VNA004', 'GREEN', 'Pending', '2024-02-03'),
('D202402002', 'CT005', 'E005', N'Nhập khẩu', 'VNA005', 'RED', 'Completed', '2024-02-07'),
('D202402003', 'CT006', 'E006', N'Xuất khẩu', 'VNA006', 'YELLOW', 'Processing', '2024-02-12'),
('D202402004', 'CT007', 'E007', N'Nhập khẩu', 'VNA007', 'GREEN', 'Completed', '2024-02-17'),
('D202402005', 'CT008', 'E008', N'Xuất khẩu', 'VNA008', 'RED', 'Pending', '2024-02-22'),
('D202402006', 'CT009', 'E009', N'Nhập khẩu', 'VNA009', 'YELLOW', 'Processing', '2024-02-27'),
('D202403001', 'CT010', 'E010', N'Xuất khẩu', 'VNA010', 'GREEN', 'Completed', '2024-03-03'),
('D202403002', 'CT011', 'E011', N'Nhập khẩu', 'VNA011', 'RED', 'Pending', '2024-03-07'),
('D202403003', 'CT012', 'E012', N'Xuất khẩu', 'VNA012', 'YELLOW', 'Processing', '2024-03-12');

-- Insert Goods_Detail data
INSERT INTO Goods_Detail (Detail_ID, Declaration_ID, Goods_ID, Quantity, Net_Weight, Gross_Weight, Total_Value) VALUES
('GD001', 'D202401001', 'G00001', 10, 50000, 52000, 150000000),
('GD002', 'D202401002', 'G00002', 20, 30000, 31000, 200000000),
('GD003', 'D202401003', 'H00001', 5, 25000, 26000, 25000000),
('GD004', 'D202402001', 'H00002', 8, 24000, 25000, 24000000),
('GD005', 'D202402002', 'P00001', 1000, 1000000, 1020000, 50000000),
('GD006', 'D202402003', 'P00002', 500, 500000, 510000, 100000000),
('GD007', 'D202402004', 'G00003', 15, 75000, 77000, 120000000),
('GD008', 'D202402005', 'H00003', 30, 30000, 31000, 30000000),
('GD009', 'D202402006', 'P00003', 800, 800000, 815000, 120000000),
('GD010', 'D202403001', 'G00004', 25, 125000, 128000, 125000000),
('GD011', 'D202403002', 'H00004', 100, 8000, 8200, 8000000),
('GD012', 'D202403003', 'P00004', 1200, 1200000, 1225000, 120000000);

-- Insert Consultation data
INSERT INTO Consultation (Consultant_ID, Customer_ID, Employee_ID, Consultant_Date, Goods_Type, Estimate_HS_Code, Estimate_Tax_Rate, Estimate_Cost, Required_Permit, Status, Notes) VALUES
(1, 'C001', 'E001', '2024-01-15', 'General Goods', 84713010, 10.00, 15000000, N'Giấy phép nhập khẩu', 'Completed', N'Cần kiểm tra kỹ thông số kỹ thuật'),
(2, 'C002', 'E002', '2024-01-20', 'General Goods', 85171200, 8.00, 10000000, N'Giấy phép nhập khẩu', 'Completed', N'Yêu cầu CO form D'),
(3, 'C003', 'E003', '2024-01-25', 'Hazardous', 28070010, 5.00, 5000000, N'Giấy phép vận chuyển hàng nguy hiểm', 'Processing', N'Cần đảm bảo điều kiện an toàn'),
(4, 'C004', 'E004', '2024-02-01', 'Hazardous', 38140000, 7.00, 3000000, N'Giấy phép vận chuyển hàng nguy hiểm', 'Pending', N'Kiểm tra quy cách đóng gói'),
(5, 'C005', 'E005', '2024-02-05', 'Perishable', 04012000, 15.00, 50000, N'Giấy kiểm dịch', 'Completed', N'Yêu cầu container lạnh'),
(6, 'C006', 'E006', '2024-02-10', 'Perishable', 02023000, 20.00, 200000, N'Giấy kiểm dịch', 'Processing', N'Kiểm tra nhiệt độ bảo quản'),
(7, 'C007', 'E007', '2024-02-15', 'General Goods', 84433100, 12.00, 8000000, N'Giấy phép nhập khẩu', 'Completed', N'Cần CO form E'),
(8, 'C008', 'E008', '2024-02-20', 'Hazardous', 32089090, 10.00, 1000000, N'Giấy phép vận chuyển hàng nguy hiểm', 'Pending', N'Kiểm tra điều kiện lưu kho'),
(9, 'C009', 'E009', '2024-02-25', 'Perishable', 03061700, 18.00, 150000, N'Giấy kiểm dịch', 'Processing', N'Yêu cầu kiểm tra chất lượng'),
(10, 'C010', 'E010', '2024-03-01', 'General Goods', 84713020, 10.00, 5000000, N'Giấy phép nhập khẩu', 'Completed', N'Kiểm tra xuất xứ'),
(11, 'C011', 'E011', '2024-03-05', 'Hazardous', 34022090, 8.00, 80000, N'Giấy phép vận chuyển hàng nguy hiểm', 'Pending', N'Cần giấy phép đặc biệt'),
(12, 'C012', 'E012', '2024-03-10', 'Perishable', 07108000, 15.00, 100000, N'Giấy kiểm dịch', 'Processing', N'Kiểm tra vệ sinh an toàn thực phẩm');

-- Insert Goods_Inspection data
INSERT INTO Goods_Inspection (Inspection_ID, Declaration_ID, Employee_ID, Inspection_Type, Schedule_Date, Inspection_Location, Status, Inspector_Name, Result, Notes) VALUES
('INS001', 'D202401001', 'E001', 'Physical', '2024-01-18', N'Cảng Cát Lái', 'Completed', N'Nguyễn Văn A', N'Đạt', N'Hàng hóa đủ khai báo'),
('INS002', 'D202401002', 'E002', 'Document', '2024-01-23', N'Cảng Sài Gòn', 'Completed', N'Trần Thị B', N'Đạt', N'Chứng từ đầy đủ'),
('INS003', 'D202401003', 'E003', 'X-ray', '2024-01-28', N'Cảng VICT', 'Processing', N'Lê Văn C', N'Chờ kết quả', N'Đang kiểm tra'),
('INS004', 'D202402001', 'E004', 'Sample Testing', '2024-02-04', N'Cảng Cát Lái', 'Pending', N'Phạm Thị D', N'Chờ kết quả', N'Lấy mẫu kiểm nghiệm'),
('INS005', 'D202402002', 'E005', 'Physical', '2024-02-08', N'Cảng Sài Gòn', 'Completed', N'Hoàng Văn E', N'Đạt', N'Hàng hóa phù hợp'),
('INS006', 'D202402003', 'E006', 'Document', '2024-02-13', N'Cảng VICT', 'Processing', N'Đỗ Thị F', N'Chờ kết quả', N'Bổ sung C/O'),
('INS007', 'D202402004', 'E007', 'X-ray', '2024-02-18', N'Cảng Cát Lái', 'Completed', N'Vũ Văn G', N'Đạt', N'Không phát hiện bất thường'),
('INS008', 'D202402005', 'E008', 'Sample Testing', '2024-02-23', N'Cảng Sài Gòn', 'Pending', N'Mai Thị H', N'Chờ kết quả', N'Đang phân tích mẫu'),
('INS009', 'D202402006', 'E009', 'Physical', '2024-02-28', N'Cảng VICT', 'Processing', N'Bùi Văn I', N'Chờ kết quả', N'Kiểm tra container'),
('INS010', 'D202403001', 'E010', 'Document', '2024-03-04', N'Cảng Cát Lái', 'Completed', N'Lý Thị K', N'Đạt', N'Chứng từ hợp lệ'),
('INS011', 'D202403002', 'E011', 'X-ray', '2024-03-08', N'Cảng Sài Gòn', 'Pending', N'Trương Văn L', N'Chờ kết quả', N'Chờ quét container'),
('INS012', 'D202403003', 'E012', 'Sample Testing', '2024-03-13', N'Cảng VICT', 'Processing', N'Ngô Thị M', N'Chờ kết quả', N'Lấy mẫu kiểm tra');

-- Insert Post_Clearance_Service data
INSERT INTO Post_Clearance_Service (Post_Clearance_Service_ID, Declaration_ID, Document_Storage_Ref, Consultant_Notes, Review_Date, Report, Improvement_Suggestion, Status) VALUES
(1, 'D202401001', 'PCS2024001', N'Lưu trữ chứng từ đầy đủ', '2024-02-15', N'Báo cáo đánh giá tuân thủ', N'Cần cập nhật quy trình lưu trữ', 'Completed'),
(2, 'D202401002', 'PCS2024002', N'Kiểm tra sau thông quan', '2024-02-20', N'Báo cáo kiểm tra', N'Tăng cường kiểm soát nội bộ', 'Completed'),
(3, 'D202401003', 'PCS2024003', N'Rà soát hồ sơ', '2024-02-25', N'Báo cáo rà soát', N'Cải thiện quy trình khai báo', 'Processing'),
(4, 'D202402001', 'PCS2024004', N'Tư vấn tuân thủ', '2024-03-01', N'Báo cáo tư vấn', N'Đào tạo nhân viên', 'Pending'),
(5, 'D202402002', 'PCS2024005', N'Đánh giá rủi ro', '2024-03-05', N'Báo cáo rủi ro', N'Xây dựng ma trận rủi ro', 'Completed'),
(6, 'D202402003', 'PCS2024006', N'Kiểm tra quy trình', '2024-03-10', N'Báo cáo quy trình', N'Cập nhật SOP', 'Processing'),
(7, 'D202402004', 'PCS2024007', N'Rà soát thuế', '2024-03-15', N'Báo cáo thuế', N'Tối ưu hóa chi phí', 'Completed'),
(8, 'D202402005', 'PCS2024008', N'Kiểm tra chứng từ', '2024-03-20', N'Báo cáo chứng từ', N'Số hóa tài liệu', 'Pending'),
(9, 'D202402006', 'PCS2024009', N'Đánh giá tuân thủ', '2024-03-25', N'Báo cáo tuân thủ', N'Tăng cường kiểm soát', 'Processing'),
(10, 'D202403001', 'PCS2024010', N'Rà soát quy trình', '2024-03-30', N'Báo cáo đánh giá', N'Cập nhật quy trình làm việc', 'Completed'),
(11, 'D202403002', 'PCS2024011', N'Kiểm tra hồ sơ', '2024-04-05', N'Báo cáo kiểm tra', N'Cải thiện lưu trữ', 'Pending'),
(12, 'D202403003', 'PCS2024012', N'Tư vấn quy trình', '2024-04-10', N'Báo cáo tư vấn', N'Nâng cao hiệu quả làm việc', 'Processing');

-- Insert Document_Set data
INSERT INTO Document_Set (Document_Set_ID, Contract_ID, Declaration_ID, Verification_Status, Notes, Status) VALUES
(10001, 'CT001', 'D202401001', N'Đã xác minh', N'Đầy đủ chứng từ', 'Completed'),
(10002, 'CT002', 'D202401002', N'Đã xác minh', N'Cần bổ sung CO', 'Completed'),
(10003, 'CT003', 'D202401003', N'Đang xác minh', N'Chờ bổ sung', 'Processing'),
(10004, 'CT004', 'D202402001', N'Chờ xác minh', N'Mới nộp hồ sơ', 'Pending'),
(10005, 'CT005', 'D202402002', N'Đã xác minh', N'Hồ sơ đầy đủ', 'Completed'),
(10006, 'CT006', 'D202402003', N'Đang xác minh', N'Đang kiểm tra', 'Processing'),
(10007, 'CT007', 'D202402004', N'Đã xác minh', N'Hoàn thành', 'Completed'),
(10008, 'CT008', 'D202402005', N'Chờ xác minh', N'Chờ xử lý', 'Pending'),
(10009, 'CT009', 'D202402006', N'Đang xác minh', N'Đang xử lý', 'Processing'),
(10010, 'CT010', 'D202403001', N'Đã xác minh', N'Hoàn tất', 'Completed'),
(10011, 'CT011', 'D202403002', N'Chờ xác minh', N'Chờ bổ sung', 'Pending'),
(10012, 'CT012', 'D202403003', N'Đang xác minh', N'Đang kiểm tra', 'Processing');

-- Insert Document data (dùng NULL cho VARBINARY)
INSERT INTO Document (Document_ID, Commercial_Invoice, Packing_List, Bill_Of_Lading, C_O, Import_Permit, Other_Certification, Document_Set_ID) VALUES
(20001, NULL, NULL, NULL, NULL, NULL, NULL, 10001),
(20002, NULL, NULL, NULL, NULL, NULL, NULL, 10002),
(20003, NULL, NULL, NULL, NULL, NULL, NULL, 10003),
(20004, NULL, NULL, NULL, NULL, NULL, NULL, 10004),
(20005, NULL, NULL, NULL, NULL, NULL, NULL, 10005),
(20006, NULL, NULL, NULL, NULL, NULL, NULL, 10006),
(20007, NULL, NULL, NULL, NULL, NULL, NULL, 10007),
(20008, NULL, NULL, NULL, NULL, NULL, NULL, 10008),
(20009, NULL, NULL, NULL, NULL, NULL, NULL, 10009),
(20010, NULL, NULL, NULL, NULL, NULL, NULL, 10010),
(20011, NULL, NULL, NULL, NULL, NULL, NULL, 10011),
(20012, NULL, NULL, NULL, NULL, NULL, NULL, 10012);

-- Insert Payment data
INSERT INTO Payment (Payment_ID, Contract_ID, Tax_Fee, Amount,
Payment_Date) VALUES
('PAY202401001', 'CT001', 5000000, 55000000, '2024-01-20'),
('PAY202401002', 'CT002', 3000000, 33000000, '2024-01-25'),
('PAY202401003', 'CT003', 4000000, 44000000, '2024-01-30'),
('PAY202402001', 'CT004', 5500000, 60500000, '2024-02-05'),
('PAY202402002', 'CT005', 3500000, 38500000, '2024-02-10'),
('PAY202402003', 'CT006', 4500000, 49500000, '2024-02-15'),
('PAY202402004', 'CT007', 5200000, 57200000, '2024-02-20'),
('PAY202402005', 'CT008', 3300000, 36300000, '2024-02-25'),
('PAY202402006', 'CT009', 4200000, 46200000, '2024-03-01'),
('PAY202403001', 'CT010', 5100000, 56100000, '2024-03-05'),
('PAY202403002', 'CT011', 3100000, 34100000, '2024-03-10'),
('PAY202403003', 'CT012', 4300000, 47300000, '2024-03-15');


