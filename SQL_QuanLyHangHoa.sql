create database ThuongMaiDienTu_Commercial
go
use ThuongMaiDienTu_Commercial
go

-- bảng người dùng
create table Users (
    UserID int identity(1,1) primary key,
    FullName nvarchar(100) not null,
    Email nvarchar(100) unique not null,
    Password nvarchar(255) not null,
    Phone nvarchar(20),
    Address nvarchar(255),
    CreatedAt datetime default getdate()
)
insert into Users(UserID, FullName, Password, Phone, Address
-- bảng danh mục sản phẩm
create table Categories (
    CategoryID int identity(1,1) primary key,
    CategoryName nvarchar(100) not null,
    Description nvarchar(255)
)

-- bảng sản phẩm
create table Products (
    ProductID int identity(1,1) primary key,
    ProductName nvarchar(255) not null,
    Price decimal(18,2) not null,
    Stock int not null,
    CategoryID int foreign key references Categories(CategoryID),
    CreatedAt datetime default getdate()
)

-- bảng đơn hàng
create table Orders (
    OrderID int identity(1,1) primary key,
    UserID int foreign key references Users(UserID),
    OrderDate datetime default getdate(),
    TotalAmount decimal(18,2) not null,
    Status nvarchar(50) default 'pending'
)

-- bảng vận chuyển
create table Shipments (
    ShipmentID int identity(1,1) primary key,
    OrderID int unique foreign key references Orders(OrderID),
    Carrier nvarchar(100) not null,
    TrackingNumber nvarchar(50) unique,
    ShippingStatus nvarchar(50) default 'processing',
    EstimatedDeliveryDate datetime,
    ShippedDate datetime
)

-- cập nhật bảng đơn hàng để thêm khóa ngoại ShipmentID sau khi tạo bảng Shipments
alter table Orders
add ShipmentID int unique foreign key references Shipments(ShipmentID);

-- bảng chi tiết đơn hàng
create table OrderDetails (
    OrderDetailID int identity(1,1) primary key,
    OrderID int foreign key references Orders(OrderID),
    ProductID int foreign key references Products(ProductID),
    Quantity int not null,
    Price decimal(18,2) not null
)

-- bảng thanh toán
create table Payments (
    PaymentID int identity(1,1) primary key,
    OrderID int foreign key references Orders(OrderID),
    PaymentMethod nvarchar(50) not null,
    PaymentStatus nvarchar(50) default 'pending',
    TransactionDate datetime default getdate()
)

-- bảng đánh giá sản phẩm
create table Reviews (
    ReviewID int identity(1,1) primary key,
    UserID int foreign key references Users(UserID),
    ProductID int foreign key references Products(ProductID),
    Rating int check (Rating between 1 and 5),
    Comment nvarchar(500),
    ReviewDate datetime default getdate()
)

-- bảng giỏ hàng
create table Carts (
    CartID int identity(1,1) primary key,
    UserID int foreign key references Users(UserID),
    CreatedAt datetime default getdate()
)

-- bảng chi tiết giỏ hàng
create table CartDetails (
    CartDetailID int identity(1,1) primary key,
    CartID int foreign key references Carts(CartID),
    ProductID int foreign key references Products(ProductID),
    Quantity int not null
)
-- tạo procedure thêm đơn hàng
create procedure AddOrder
    @UserID int,
    @TotalAmount decimal(18,2)
as
begin
    insert into Orders (UserID, TotalAmount) values (@UserID, @TotalAmount);
end;

go

-- tạo view danh sách đơn hàng
create view ViewOrders as
select o.OrderID, u.FullName, o.OrderDate, o.TotalAmount, o.Status
from Orders o
join Users u on o.UserID = u.UserID;

go

-- tạo trigger cập nhật số lượng sản phẩm khi đặt hàng
create trigger trg_UpdateStock on OrderDetails
after insert
as
begin
    update Products
    set Stock = Stock - i.Quantity
    from Products p
    inner join inserted i on p.ProductID = i.ProductID;
end;
