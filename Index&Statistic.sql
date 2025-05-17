---Giúp tối ưu các truy vấn lọc theo khoảng thời gian thanh toán (Payment_Date) và liên kết hợp đồng (Contract_ID)
CREATE NONCLUSTERED INDEX IX_Payment_Date_Contract
ON Payment (Payment_Date, Contract_ID)
INCLUDE (Tax_Fee, Amount);
GO

--------Tối ưu các truy vấn phân tích hoặc lọc theo loại khai báo (Declaration_Type) và trạng thái (Status) của khai báo hải quan
CREATE NONCLUSTERED INDEX IX_CustomerDeclaration_DeclType_Status
ON Customer_Declaration (Declaration_Type, Status)
INCLUDE (Submission_Date, Contract_ID);
GO
-------Tối ưu các truy vấn liên quan đến khai báo hải quan (Declaration_ID) và tính toán số lượng, giá trị hàng hóa
CREATE NONCLUSTERED INDEX IX_GoodsDetail_Declaration_Quantity
ON Goods_Detail (Declaration_ID, Quantity)
INCLUDE (Goods_ID, Total_Value);
GO
-----
CREATE NONCLUSTERED INDEX IX_GoodsDetail_GoodsID
ON Goods_Detail (Goods_ID)
INCLUDE (Quantity, Total_Value);
GO

-------hỗ trợ lựa chọn kế hoạch thực thi tối ưu khi truy vấn theo thuế
CREATE STATISTICS ST_Payment_TaxFee
ON Payment (Tax_Fee) WITH SAMPLE 100 PERCENT;
GO
---------Cung cấp thông tin về phân bố ngày nộp khai báo hải quan
CREATE STATISTICS ST_CustomerDeclaration_SubmissionDate
ON Customer_Declaration (Submission_Date) WITH FULLSCAN;
GO
--------Giúp tối ưu các truy vấn tính tổng số lượng hàng hóa theo từng khai báo
CREATE STATISTICS ST_GoodsDetail_Quantity
ON Goods_Detail (Quantity) WITH SAMPLE 50 PERCENT;
GO
--------lọc hoặc tính toán theo Amount
CREATE STATISTICS ST_Payment_Amount
ON Payment (Amount) WITH FULLSCAN;
GO
-----truy vấn lọc theo cột Status
CREATE NONCLUSTERED INDEX IX_ServiceRequest_Status
ON Service_Request (Status)
INCLUDE (Request_Date);
GO

CREATE STATISTICS ST_ServiceRequest_RequestDate
ON Service_Request (Request_Date) WITH SAMPLE 100 PERCENT;
GO

----
SELECT name, index_id, type_desc 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('Payment');
-----
SELECT 
    i.name, 
    s.user_seeks, s.user_scans, s.user_lookups, s.user_updates
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats s
    ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE i.object_id = OBJECT_ID('Payment');
--------
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Payment_ID, Payment_Date, Tax_Fee, Amount
FROM Payment
WHERE Payment_Date BETWEEN '2024-03-01' AND '2024-03-10';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
------
DBCC SHOW_STATISTICS ('Payment', 'ST_Payment_TaxFee');
-------kiểm tra mức độ phân mảnh
SELECT 
    dbschemas.name AS SchemaName,
    dbtables.name AS TableName,
    dbindexes.name AS IndexName,
    indexstats.index_id,
    indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'DETAILED') AS indexstats
    INNER JOIN sys.tables dbtables on indexstats.object_id = dbtables.object_id
    INNER JOIN sys.schemas dbschemas on dbtables.schema_id = dbschemas.schema_id
    INNER JOIN sys.indexes dbindexes on dbindexes.object_id = indexstats.object_id 
                                     AND dbindexes.index_id = indexstats.index_id
ORDER BY avg_fragmentation_in_percent DESC;