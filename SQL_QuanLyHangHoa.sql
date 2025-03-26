-- Tạo cơ sở dữ liệu
CREATE DATABASE E__Commercial;
GO
USE E__Commercial;
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
);

-- Bảng danh mục sản phẩm
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255)
);

-- Bảng sản phẩm
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(255) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Stock INT NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng đơn hàng
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'pending'
);

-- Bảng vận chuyển (đã sửa để không bắt buộc OrderID phải duy nhất)
CREATE TABLE Shipments (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID) ON DELETE CASCADE,
    Carrier NVARCHAR(100) NOT NULL,
    TrackingNumber NVARCHAR(50) UNIQUE,
    ShippingStatus NVARCHAR(50) DEFAULT 'processing',
    EstimatedDeliveryDate DATETIME,
    ShippedDate DATETIME
);

-- Bảng chi tiết đơn hàng
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL
);

-- Bảng thanh toán
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    PaymentMethod NVARCHAR(50) NOT NULL,
    PaymentStatus NVARCHAR(50) DEFAULT 'pending',
    TransactionDate DATETIME DEFAULT GETDATE()
);

-- Bảng đánh giá sản phẩm
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(500),
    ReviewDate DATETIME DEFAULT GETDATE()
);

-- Bảng giỏ hàng
CREATE TABLE Carts (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Bảng chi tiết giỏ hàng
CREATE TABLE CartDetails (
    CartDetailID INT IDENTITY(1,1) PRIMARY KEY,
    CartID INT FOREIGN KEY REFERENCES Carts(CartID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL
);

GO

-- Thêm dữ liệu vào bảng Users
INSERT INTO Users (FullName, Email, Password, Phone, Address) VALUES
('Nguyễn Văn A', 'nguyenvana@example.com', 'password123', '0123456789', 'Hà Nội'),
('Trần Thị B', 'tranthib@example.com', 'password123', '0987654321', 'TP Hồ Chí Minh'),
('Lê Văn C', 'levanc@example.com', 'password123', '0345678901', 'Đà Nẵng');

-- Thêm dữ liệu vào bảng Categories
INSERT INTO Categories (CategoryName, Description) VALUES
('Điện thoại', 'Các loại điện thoại thông minh'),
('Laptop', 'Máy tính xách tay các hãng'),
('Phụ kiện', 'Các loại phụ kiện công nghệ');

-- Thêm dữ liệu vào bảng Products
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('iPhone 14', 25000000, 10, 1),
('Samsung Galaxy S23', 23000000, 15, 1),
('MacBook Pro 16', 60000000, 5, 2),
('Dell XPS 15', 45000000, 8, 2),
('Tai nghe AirPods Pro', 5000000, 20, 3);

-- Thêm dữ liệu vào bảng Orders
INSERT INTO Orders (UserID, TotalAmount) VALUES
(1, 25000000),
(2, 23000000),
(3, 5000000);

-- Thêm dữ liệu vào bảng Shipments
INSERT INTO Shipments (OrderID, Carrier, TrackingNumber, ShippingStatus, EstimatedDeliveryDate, ShippedDate) VALUES
(1, 'VNPost', 'VN123456', 'shipped', '2025-03-30', '2025-03-27'),
(2, 'DHL', 'DHL789012', 'processing', '2025-04-02', NULL);

-- Thêm dữ liệu vào bảng OrderDetails
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 25000000),
(2, 2, 1, 23000000),
(3, 5, 1, 5000000);

-- Thêm dữ liệu vào bảng Payments
INSERT INTO Payments (OrderID, PaymentMethod, PaymentStatus) VALUES
(1, 'Credit Card', 'completed'),
(2, 'PayPal', 'pending'),
(3, 'Bank Transfer', 'completed');

-- Thêm dữ liệu vào bảng Reviews
INSERT INTO Reviews (UserID, ProductID, Rating, Comment) VALUES
(1, 1, 5, 'Sản phẩm rất tốt, đáng tiền!'),
(2, 2, 4, 'Điện thoại đẹp, nhưng pin hơi yếu.'),
(3, 5, 5, 'Âm thanh rất tuyệt vời.');

-- Thêm dữ liệu vào bảng Carts
INSERT INTO Carts (UserID) VALUES
(1), (2), (3);

-- Thêm dữ liệu vào bảng CartDetails
INSERT INTO CartDetails (CartID, ProductID, Quantity) VALUES
(1, 3, 1),
(2, 4, 1),
(3, 5, 2);



-- Tạo procedure thêm đơn hàng
CREATE PROCEDURE AddOrder
    @UserID INT,
    @TotalAmount DECIMAL(18,2)
AS
BEGIN
    INSERT INTO Orders (UserID, TotalAmount) VALUES (@UserID, @TotalAmount);
END;
GO

-- Tạo view danh sách đơn hàng
CREATE VIEW ViewOrders AS
SELECT o.OrderID, u.FullName, o.OrderDate, o.TotalAmount, o.Status
FROM Orders o
JOIN Users u ON o.UserID = u.UserID;
GO

-- Tạo trigger cập nhật số lượng sản phẩm khi đặt hàng
CREATE TRIGGER trg_UpdateStock ON OrderDetails
AFTER INSERT
AS
BEGIN
    UPDATE Products
    SET Stock = Stock - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
