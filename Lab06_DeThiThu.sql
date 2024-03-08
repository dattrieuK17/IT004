---Câu 1:
create database BAITHI
use BAITHI
set dateformat DMY
create table NHACUNGCAP(
	MANCC char(5) primary key,
	TENNCC char(50),
	QUOCGIA	char(15),
	LOAINCC char(15)
)

create table DUOCPHAM(
	MADP char(5) primary key,
	TENDP char(50),
	LOAIDP char(15),
	GIA smallmoney
)

create table PHIEUNHAP(
	SOPN char(10) primary key,
	NGNHAP datetime,
	MANCC char(5) foreign key (MANCC) references NHACUNGCAP(MANCC),
	LOAINHAP char(20)
)

create table CTPN(
	SOPN char(10) foreign key (SOPN) references PHIEUNHAP(SOPN),
	MADP char(5) foreign key (MADP) references DUOCPHAM(MADP),
	SOLUONG smallint,
	primary key (SOPN, MADP)
)

---Câu 2:
insert into NHACUNGCAP values ('NCC01', 'Phuc Hung', 'Viet Nam', 'Thuong xuyen')
insert into NHACUNGCAP values ('NCC02', 'J. B. Pharmaceuticals', 'India', 'Vang lai')
insert into NHACUNGCAP values ('NCC03', 'Sapharco', 'Singapore', 'Vang lai')

insert into DUOCPHAM values ('DP01', 'Thuoc ho PH', 'Siro', 120.000)
insert into DUOCPHAM values ('DP02', 'Zecuf Herbal CouchRemedy', 'Vien nen', 200.000)
insert into DUOCPHAM values ('DP03', 'Cotrim', 'Vien sui', 80.000)

insert into PHIEUNHAP values ('00001', '22/11/2017', 'NCC01', 'Noi dia')
insert into PHIEUNHAP values ('00002', '04/12/2017', 'NCC03', 'Nhap khau')
insert into PHIEUNHAP values ('00003', '10/12/2017', 'NCC02', 'Nhap khau')

insert into CTPN values ('00001', 'DP01', 100)
insert into CTPN values ('00001', 'DP02', 200)
insert into CTPN values ('00003', 'DP03', 543)

---Câu 3:
alter table DUOCPHAM add constraint ck_LOAI_GIA check(LOAIDP <> 'Siro' or GIA > 100000)

---Câu 4:
---				Them		Xoa			Sua
---NHACUNGCAP	 -			 -			 +(QUOCGIA)
---PHIEUNHAP	 +			 -			 +(LOAINHAP, MACC)
create trigger trg_SUA_NHACUNGCAP on NHACUNGCAP
for update
as if update(QUOCGIA)
begin
	if exists (select * 
			   from inserted i join PHIEUNHAP pn on i.MANCC = pn.MANCC
			   where i.QUOCGIA <> 'Viet Nam' and pn.LOAINHAP <> 'Nhap khau')
	begin 
		rollback transaction
	end
end 

create trigger trg_THEM_PHIEUNHAP on PHIEUNHAP
for insert, update 
as
begin
	update PHIEUNHAP
	set LOAINHAP = 'Nhap khau'
	where SOPN in (select SOPN
				   from inserted i join NHACUNGCAP ncc on i.MANCC = ncc.MANCC
				   where ncc.QUOCGIA <> 'Viet Nam'
				   )
	print 'Da cap nhat lai LOAINHAP'
end

---Câu 5:
select *
from PHIEUNHAP 
where year(NGNHAP) = 2017 and month(NGNHAP) = 12
order by day(NGNHAP) asc

---Câu 6:
select *
from DUOCPHAM
where MADP in (select top(1) with ties MADP
			   from PHIEUNHAP pn join CTPN ct on pn.SOPN = ct.SOPN
			   where year(NGNHAP) = 2017
			   group by MADP
			   order by sum(SOLUONG) desc 
			   )

---Câu 7:
select *
from duocpham
where MADP in (select MADP
			   from NHACUNGCAP ncc join PHIEUNHAP pn on ncc.MANCC = pn.MANCC
								   join	CTPN ct on pn.SOPN = ct.SOPN
			   where LOAINCC = 'Thuong xuyen'
			   except
			   select MADP
			   from NHACUNGCAP ncc join PHIEUNHAP pn on ncc.MANCC = pn.MANCC
								   join	CTPN ct on pn.SOPN = ct.SOPN
			   where LOAINCC = 'Vang lai'
			   )

---Câu 8:
select *
from NHACUNGCAP
where MANCC in (select MANCC
				from PHIEUNHAP pn join CTPN ct on pn.SOPN = ct.SOPN
								  join DUOCPHAM dp on ct.MADP = dp.MADP
				where GIA > 100.000 and year(NGNHAP) = 2017
				group by MANCC
				having count (ct.MADP) = (select count(MADP)
										  from DUOCPHAM dp
										  where GIA > 100.000 ))