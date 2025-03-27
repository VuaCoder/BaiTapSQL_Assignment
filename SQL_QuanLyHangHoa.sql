-- Tạo cơ sở dữ liệu
CREATE DATABASE E__Commercial
GO
USE E__Commercial
GO

-- Bảng người dùng
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE()
)
ALTER TABLE Users ADD IsAdmin BIT DEFAULT 0;
-- Bảng danh mục sản phẩm
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255)
)

-- Bảng sản phẩm
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(255) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Stock INT NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    CreatedAt DATETIME DEFAULT GETDATE()
)

-- Bảng đơn hàng
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'pending'
)

-- Bảng vận chuyển (đã sửa để không bắt buộc OrderID phải duy nhất)
CREATE TABLE Shipments (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID) ON DELETE CASCADE,
    Carrier NVARCHAR(100) NOT NULL,
    TrackingNumber NVARCHAR(50) UNIQUE,
    ShippingStatus NVARCHAR(50) DEFAULT 'processing',
    EstimatedDeliveryDate DATETIME,
    ShippedDate DATETIME
)

-- Bảng chi tiết đơn hàng
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL
)

-- Bảng thanh toán
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    PaymentMethod NVARCHAR(50) NOT NULL,
    PaymentStatus NVARCHAR(50) DEFAULT 'pending',
    TransactionDate DATETIME DEFAULT GETDATE()
)

-- Bảng đánh giá sản phẩm
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(500),
    ReviewDate DATETIME DEFAULT GETDATE()
)

-- Bảng giỏ hàng
CREATE TABLE Carts (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    CreatedAt DATETIME DEFAULT GETDATE()
)

-- Bảng chi tiết giỏ hàng
CREATE TABLE CartDetails (
    CartDetailID INT IDENTITY(1,1) PRIMARY KEY,
    CartID INT FOREIGN KEY REFERENCES Carts(CartID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL
)

-- Thêm dữ liệu vào bảng Users
INSERT INTO Users (FullName, Email, Password, Phone, Address) VALUES
('Nguyễn Văn A', 'nguyenvana@example.com', 'password123', '0123456789', 'Hà Nội'),
('Trần Thị B', 'tranthib@example.com', 'password123', '0987654321', 'TP Hồ Chí Minh'),
('Lê Văn C', 'levanc@example.com', 'password123', '0345678901', 'Đà Nẵng')
-- Thêm dữ liệu vào bảng Categories
INSERT INTO Categories (CategoryName, Description) VALUES
('Điện thoại', 'Các loại điện thoại thông minh'),
('Laptop', 'Máy tính xách tay các hãng'),
('Phụ kiện', 'Các loại phụ kiện công nghệ')
-- Thêm dữ liệu vào bảng Products
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('iPhone 14', 25000000, 10, 1),
('Samsung Galaxy S23', 23000000, 15, 1),
('MacBook Pro 16', 60000000, 5, 2),
('Dell XPS 15', 45000000, 8, 2),
('Tai nghe AirPods Pro', 5000000, 20, 3)
-- Thêm dữ liệu vào bảng Orders
INSERT INTO Orders (UserID, TotalAmount) VALUES
(1, 25000000),
(2, 23000000),
(3, 5000000)
-- Thêm dữ liệu vào bảng Shipments
INSERT INTO Shipments (OrderID, Carrier, TrackingNumber, ShippingStatus, EstimatedDeliveryDate, ShippedDate) VALUES
(1, 'VNPost', 'VN123456', 'shipped', '2025-03-30', '2025-03-27'),
(2, 'DHL', 'DHL789012', 'processing', '2025-04-02', NULL);
-- Thêm dữ liệu vào bảng OrderDetails
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 25000000),
(2, 2, 1, 23000000),
(3, 5, 1, 5000000)
-- Thêm dữ liệu vào bảng Payments
INSERT INTO Payments (OrderID, PaymentMethod, PaymentStatus) VALUES
(1, 'Credit Card', 'completed'),
(2, 'PayPal', 'pending'),
(3, 'Bank Transfer', 'completed')
-- Thêm dữ liệu vào bảng Reviews
INSERT INTO Reviews (UserID, ProductID, Rating, Comment) VALUES
(1, 1, 5, 'Sản phẩm rất tốt, đáng tiền!'),
(2, 2, 4, 'Điện thoại đẹp, nhưng pin hơi yếu.'),
(3, 5, 5, 'Âm thanh rất tuyệt vời.')
-- Thêm dữ liệu vào bảng Carts
INSERT INTO Carts (UserID) VALUES
(1), (2), (3)
-- Thêm dữ liệu vào bảng CartDetails
INSERT INTO CartDetails (CartID, ProductID, Quantity) VALUES
(1, 3, 1),
(2, 4, 1),
(3, 5, 2)
--------------------------------------------------------------------
-- Hoàng Phúc
-- Thêm đơn hàng
CREATE PROCEDURE AddOrder
    @UserID INT,
    @TotalAmount DECIMAL(18,2)
AS
BEGIN
    INSERT INTO Orders (UserID, TotalAmount) VALUES (@UserID, @TotalAmount)
END
EXEC AddOrder @UserID = 1, @TotalAmount = 25000000

-- Danh sách đơn hàng
CREATE VIEW ViewOrders AS
SELECT o.OrderID, u.FullName, o.OrderDate, o.TotalAmount, o.Status
FROM Orders o
JOIN Users u ON o.UserID = u.UserID;
select * from ViewOrders

-- Cập nhật số lượng sản phẩm khi đặt hàng
CREATE TRIGGER trg_UpdateStock ON OrderDetails
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Products p ON i.ProductID = p.ProductID
        WHERE p.Stock < i.Quantity
    )
    BEGIN
        RAISERROR ('Số lượng sản phẩm không đủ trong kho.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN
    END

    UPDATE Products
    SET Stock = Stock - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END
--------------------------------------------------------------------
-- Quang Minh
-- Tổng đơn hàng orders
CREATE FUNCTION GetTotalOrders(@UserID INT)  
RETURNS INT  
AS  
BEGIN  
    DECLARE @TotalOrders INT;  
    SELECT @TotalOrders = COUNT(*) FROM Orders WHERE UserID = @UserID;  
    RETURN @TotalOrders;  
END
SELECT dbo.GetTotalOrders(1) AS TotalOrders

-- Tự động tạo bảng thanh toán khi có đơn hàng mới
CREATE PROCEDURE CreateOrderWithPayment1
    @UserID INT,
    @TotalAmount DECIMAL(18,2),
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    DECLARE @OrderID INT;
    INSERT INTO Orders (UserID, TotalAmount) 
    VALUES (@UserID, @TotalAmount);
    SELECT TOP 1 @OrderID = OrderID 
    FROM Orders 
    WHERE UserID = @UserID 
    ORDER BY OrderDate DESC;
    INSERT INTO Payments (OrderID, PaymentMethod, PaymentStatus) 
    VALUES (@OrderID, @PaymentMethod, 'pending');
    PRINT 'Đã tạo đơn hàng và thanh toán thành công!';
END

EXEC CreateOrderWithPayment1 
    @UserID = 1, 
    @TotalAmount = 500000, 
    @PaymentMethod = 'Bank Transfer';
select * from Payments
-- Cập nhật thanh toán ( thủ công )
UPDATE Payments
SET PaymentStatus = 'completed'
WHERE OrderID = 1 

-- Cập nhật thanh toán ( tự động )
CREATE TRIGGER trg_UpdatePaymentStatus
ON Orders
AFTER UPDATE
AS
BEGIN
    UPDATE Payments
    SET PaymentStatus = 'completed'
    FROM Payments p
    JOIN inserted i ON p.OrderID = i.OrderID
    WHERE i.Status = 'completed';
END
--------------------------------------------------------------------
-- Xuân Thịnh
-- Gợi ý sản phẩm 
CREATE PROCEDURE SuggestProductsForUser
    @userID INT,
    @limitNum INT
AS
BEGIN
    SET NOCOUNT ON
    SELECT DISTINCT TOP (@limitNum) 
        p.ProductID, p.ProductName, p.Price
    FROM Products p
    JOIN Categories c ON p.CategoryID = c.CategoryID
    WHERE c.CategoryID IN (
        SELECT DISTINCT p2.CategoryID
        FROM OrderDetails od
        JOIN Orders o ON od.OrderID = o.OrderID
        JOIN Products p2 ON od.ProductID = p2.ProductID
        WHERE o.UserID = @userID
    )
    AND p.ProductID NOT IN (
        SELECT DISTINCT od.ProductID
        FROM OrderDetails od
        JOIN Orders o ON od.OrderID = o.OrderID
        WHERE o.UserID = @userID
    )
END

-- Lịch sử giao dịch của người dùng
CREATE PROCEDURE GetUserTransactionHistory
    @userID INT
AS
BEGIN
    SELECT 
        o.OrderID, o.OrderDate, o.TotalAmount, o.Status AS OrderStatus,
        p.PaymentMethod, p.PaymentStatus, p.TransactionDate
    FROM Orders o
    LEFT JOIN Payments p ON o.OrderID = p.OrderID
    LEFT JOIN Shipments s ON o.OrderID = s.OrderID
    WHERE o.UserID = @userID
	AND o.Status <> 'pending'
    ORDER BY o.OrderDate DESC
END

EXEC GetUserTransactionHistory @userID = 1
--------------------------------------------------------------------
-- Quốc Đạt 
-- Huỷ đơn hàng
CREATE PROCEDURE CancelOrder
    @OrderID INT
AS
BEGIN
    DECLARE @OrderStatus NVARCHAR(50);
    SELECT @OrderStatus = Status FROM Orders WHERE OrderID = @OrderID;
    IF @OrderStatus IN ('pending', 'completed') 
    BEGIN
        UPDATE Products
        SET Stock = Stock + od.Quantity
        FROM Products p
        INNER JOIN OrderDetails od ON p.ProductID = od.ProductID
        WHERE od.OrderID = @OrderID;
        UPDATE Orders
        SET Status = 'canceled'
        WHERE OrderID = @OrderID;

        PRINT 'Đơn hàng đã bị hủy và sản phẩm đã được hoàn lại kho!';
    END
    ELSE 
    BEGIN
        RAISERROR ('Không thể hủy đơn hàng vì đơn hàng đã/đang được vận chuyển!', 16, 1);
    END
END

-- Kiểm tra order trước khi thanh toán
CREATE TRIGGER trg_CheckOrderBeforePayment
ON Payments
BEFORE INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Orders o
        JOIN inserted i ON o.OrderID = i.OrderID
        WHERE o.Status = 'canceled'
    )
    BEGIN
        RAISERROR ('Không thể thanh toán cho đơn hàng đã bị hủy!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END
--------------------------------------------------------------------
-- Thành Công
-- Cập nhật tình trạng Ship sau khi thanh toán
CREATE TRIGGER trg_UpdateShipmentStatus
ON Payments
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted WHERE PaymentStatus = 'completed'
    )
    BEGIN
        UPDATE Shipments
        SET ShippingStatus = 'shipped', ShippedDate = GETDATE()
        WHERE OrderID IN (SELECT OrderID FROM inserted);
    END
END
-- Cập nhật order status sau khi thanh toán
CREATE PROCEDURE UpdateOrderStatusAfterPayment
    @orderID INT
AS
BEGIN
    SET NOCOUNT ON
    UPDATE Orders
    SET Status = 'completed'
    WHERE OrderID = @orderID 
    AND Status = 'pending' 
    AND EXISTS (
        SELECT 1 FROM Payments 
        WHERE OrderID = @orderID AND PaymentStatus = 'completed'
    )
END
EXEC UpdateOrderStatusAfterPayment @orderID = 1
