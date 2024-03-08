USE QUANLIGIAOVU

---Câu 9:
---			Them      Xoa     Sua
---LOP		 +         -       +(TRGLOP)
---HOCVIEN   -         +       +(MALOP)
GO

CREATE TRIGGER tg_THEM_LOP ON LOP
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I, HOCVIEN HV
			   WHERE I.TRGLOP = HV.MAHV AND HV.MALOP <> I.MALOP)
	BEGIN 
		PRINT 'LOI: LOP TRUONG KHONG PHAI LA HOC VIEN CUA LOP!'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'THEM/SUA LOP THANH CONG!'
	END
END
GO

CREATE TRIGGER tg_XOA_HOCVIEN on HOCVIEN
FOR DELETE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM deleted D, LOP L
			   WHERE D.MAHV = L.TRGLOP)
	BEGIN 
		PRINT 'LOI: LOP TRUONG KHONG PHAI LA HOC VIEN CUA LOP!'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'XOA HOCVIEN THANH CONG!'
	END
END
GO

CREATE TRIGGER tg_SUA_HOCVIEN_9 on HOCVIEN
FOR UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I, LOP L
			   WHERE I.MAHV = L.TRGLOP AND I.MALOP <> L.MALOP)
	BEGIN 
		PRINT 'LOI: LOP TRUONG KHONG PHAI LA HOC VIEN CUA LOP!'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'SUA HOCVIEN THANH CONG!'
	END
END
GO

---Câu 10:
---			Them      Xoa     Sua
---KHOA		 +         -       +(TRGKHOA)
---GIAOVIEN  -         +       +(MAKHOA, HOCVI)
CREATE TRIGGER tg_THEM_SUA_KHOA	ON KHOA
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I, GIAOVIEN GV
			   WHERE (I.TRGKHOA = GV.MAGV) AND (I.MAKHOA <> GV.MAKHOA OR  GV.HOCVI NOT IN ('TS', 'PTS')))
	BEGIN 
		PRINT 'LỖI: Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS” !'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'THÊM / SỬA KHOA THÀNH CÔNG!'
	END
END
GO

CREATE TRIGGER tg_XOA_GIAOVIEN ON GIAOVIEN
FOR DELETE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM deleted D, KHOA K
			   WHERE D.MAGV = K.TRGKHOA)
	BEGIN 
		PRINT 'LỖI: Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS” !'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'XÓA GIÁO VIÊN THÀNH CÔNG!'
	END
END
GO

CREATE TRIGGER tg_SUA_GIAOVIEN ON GIAOVIEN
FOR UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I, KHOA K
			   WHERE (I.MAKHOA = K.TRGKHOA) AND (I.MAKHOA <> K.MAKHOA OR I.HOCVI NOT IN ('TS', 'PTS')))
	BEGIN 
		PRINT 'LỖI: Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS” !'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'SỬA GIÁO VIÊN THÀNH CÔNG!'
	END
END
GO 

---Câu 15:
---			Them      Xoa     Sua
---HOCVIEN	 -         -       +(MALOP)
---GIANGDAY  -		   +	   +(DENNGAY)
---KETQUATHI +		   -	   +(NGTHI)
CREATE TRIGGER tg_SUA_HOCVIEN_15 ON HOCVIEN
FOR UPDATE
AS
BEGIN
	IF EXISTS (SELECT * 
			   FROM inserted I, GIANGDAY GD, KETQUATHI KQ
			   WHERE I.MAHV = KQ.MAHV AND I.MALOP = GD.MALOP
					AND (KQ.MAMH NOT IN (SELECT MAMH
										 FROM GIANGDAY GD
										 WHERE GD.MALOP = I.MALOP AND GD.DENNGAY < KQ.NGTHI)
						OR 
						(KQ.MAMH = GD.MAMH AND KQ.NGTHI < GD.DENNGAY)))
	BEGIN
		PRINT 'LỖI: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'SỬA HỌC VIÊN THÀNH CÔNG'
	END
END
GO

CREATE TRIGGER tg_XOA_GIANGDAY_15 ON GIANGDAY
FOR DELETE 
AS 
BEGIN
	IF EXISTS (SELECT *
			   FROM HOCVIEN HV, KETQUATHI KQ
			   WHERE HV.MAHV = KQ.MAHV AND KQ.MAMH IN (SELECT MAMH 
													   FROM deleted D
										 			   WHERE D.MALOP = HV.MALOP AND D.DENNGAY < KQ.NGTHI))
	BEGIN
		PRINT 'LỖI: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'XÓA GIẢNG DẠY THÀNH CÔNG'
	END
END
GO

CREATE TRIGGER tg_SUA_GIANGDAY_15 ON GIANGDAY
FOR UPDATE 
AS 
BEGIN
	IF EXISTS (SELECT * 
			   FROM inserted I, HOCVIEN HV, KETQUATHI KQ
			   WHERE I.MALOP = HV.MALOP AND HV.MAHV = KQ.MAHV AND I.DENNGAY > KQ.NGTHI)
	BEGIN
		PRINT 'LỖI: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'SỬA GIẢNG DẠY THÀNH CÔNG'
	END
END
GO

CREATE TRIGGER tg_THEM_SUA_KETQUATHI_15 ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT * 
			   FROM inserted I, GIANGDAY GD, HOCVIEN HV
			   WHERE I.MAHV = HV.MAHV AND I.MAMH = GD.MAMH
					AND (I.MAMH NOT IN (SELECT MAMH
										 FROM GIANGDAY GD
										 WHERE GD.MALOP = HV.MALOP AND GD.DENNGAY < I.NGTHI)
						OR 
						(I.MAMH = GD.MAMH AND I.NGTHI < GD.DENNGAY)))
	BEGIN
		PRINT 'LỖI: Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'THÊM/SỬA KẾT QUẢ THI THÀNH CÔNG'
	END
END
GO

---Câu 16:
---			Them      Xoa     Sua
---GIANGDAY  +		   -	   +(HOCKY, NAM)

CREATE TRIGGER tg_THEM_SUA ON GIANGDAY
FOR INSERT, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT *
			   FROM
					(SELECT A.MALOP, A.HOCKY, A.NAM, A.SL1 + B.SL2 AS SL 
					FROM ((SELECT MALOP, HOCKY, NAM, COUNT(*) AS SL1
						 FROM inserted I
						 GROUP BY MALOP, HOCKY, NAM
						 ) AS A
							JOIN 
						 (SELECT MALOP, HOCKY, NAM, COUNT(*) AS SL2
						 FROM GIANGDAY
						 GROUP BY MALOP, HOCKY, NAM
						 ) AS B
						 ON A.MALOP = B.MALOP AND A.HOCKY = B.HOCKY AND A.NAM = B.NAM)) as C
				WHERE SL > 3)
	BEGIN
		PRINT 'LỖI: Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'THÊM/SỬA GIẢNG DẠY THÀNH CÔNG'
	END
END
GO

---Câu 17:
---			Them      Xoa     Sua
---LOP		  +		   -	   +(SISO)
---HOCVIEN	  +		   +	   +(MALOP)

CREATE TRIGGER tg_THEM_SUA_LOP_17 ON LOP
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM INSERTED I
			   WHERE SISO <> (SELECT COUNT(MAHV)
							  FROM HOCVIEN HV
							  WHERE HV.MALOP = I.MALOP))
	BEGIN
		PRINT 'LỖI: Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'THÊM/SỬA LỚP THÀNH CÔNG'
	END
END
GO

CREATE TRIGGER tg_THEM_SUA_HOCVIEN_17 ON HOCVIEN
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	IF EXISTS (SELECT MAHV
			   FROM inserted I
			   WHERE MAHV IS NOT NULL
			   UNION
			   SELECT MAHV
			   FROM deleted D
			   WHERE MAHV IS NOT NULL)
	BEGIN
		PRINT 'LỖI: Không được thêm xóa sửa HOCVIEN'
		ROLLBACK TRANSACTION
	END
END
GO


---Câu 18:
---			Them      Xoa     Sua
---DIEUKIEN   +		   -	   -(*)
CREATE TRIGGER tg_THEM_DIEUKIEN_18 ON DIEUKIEN
FOR INSERT
AS 
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I
			   WHERE I.MAMH_TRUOC = I.MAMH
			   UNION
			   SELECT I.MAMH_TRUOC, I.MAMH
			   FROM inserted I JOIN DIEUKIEN D ON I.MAMH = D.MAMH_TRUOC
			   WHERE I.MAMH_TRUOC = D.MAMH
			   )
	BEGIN
		PRINT 'LỖI: Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”).'
		ROLLBACK TRANSACTION 
	END
	ELSE
	BEGIN
		PRINT 'THÊM DIEUKIEN THÀNH CÔNG'
	END
END
GO

---Câu 19
---			Them      Xoa     Sua
---GIAOVIEN   +		   -	   +(MUCLUONG)

CREATE TRIGGER tg_THEM_SUA_GIAOVIEN_19 ON GIAOVIEN
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I
			   WHERE EXISTS (SELECT *
							 FROM GIAOVIEN GV
							 WHERE GV.HOCHAM = I.HOCHAM AND GV.HOCVI = I.HOCVI AND GV.HESO = I.HESO AND GV.MUCLUONG <> I.MUCLUONG
							 )
				)
	BEGIN
		PRINT 'LỖI: Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.'
		ROLLBACK TRANSACTION 
	END
	ELSE
	BEGIN
		PRINT 'THÊM/SỬA GIAOVIEN THÀNH CÔNG'
	END
END
GO

---Câu 20:
---			Them      Xoa     Sua
---KETQUATHI +		   -	   +(DIEM)
CREATE TRIGGER tg_THEM_SUA_KETQUATHI_20 ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I
			   WHERE EXISTS (SELECT *
							 FROM KETQUATHI	KQT
							 WHERE I.MAHV = KQT.MAHV AND I.MAMH = KQT.MAMH AND I.LANTHI > KQT.LANTHI AND KQT.DIEM >= 5)
				)
	BEGIN
		PRINT 'LỖI: Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5'
		ROLLBACK TRANSACTION 
	END
	ELSE
	BEGIN
		PRINT 'THÊM/SỬA KETQUATHI THÀNH CÔNG'
	END
END
GO

---Câu 21:
---			Them      Xoa     Sua
---KETQUATHI +		   -	   +(NGTHI)
CREATE TRIGGER tg_THEM_SUA_KETQUATHI_2 ON KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I
			   WHERE EXISTS (SELECT *
							 FROM KETQUATHI	KQT
							 WHERE I.MAHV = KQT.MAHV AND I.MAMH = KQT.MAMH AND I.LANTHI > KQT.LANTHI AND I.NGTHI < KQT.NGTHI)
				)
	BEGIN
		PRINT 'LỖI: Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).'
		ROLLBACK TRANSACTION 
	END
	ELSE
	BEGIN
		PRINT 'THÊM/SỬA KETQUATHI THÀNH CÔNG'
	END
END
GO

---Câu 22:
---			Them      Xoa     Sua
---GIANGDAY   +		   +	   +(HOCKY, NAM, TUNGAY, DENNGAY)

CREATE TRIGGER tg_THEM_SUA_GIANGDAY_22 ON GIANGDAY
FOR INSERT, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I
			   WHERE EXISTS (SELECT * 
							 FROM GIANGDAY GD 
							 WHERE I.MALOP = GD.MALOP 
								AND I.HOCKY > GD.HOCKY AND I.NAM >= GD.NAM								
								AND I.MAMH NOT IN (SELECT MAMH
												   FROM DIEUKIEN
												   WHERE GD.MAMH = DIEUKIEN.MAMH_TRUOC)
							)
				)
	BEGIN
		PRINT 'LỖI: Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học xong những môn học phải học trước mới được học những môn liền sau).'
		ROLLBACK TRANSACTION 
	END
	ELSE
	BEGIN
		PRINT 'THÊM GIANGDAY THÀNH CÔNG'
	END
END
GO

CREATE TRIGGER tg_XOA_GIANGDAY_22 ON GIANGDAY
FOR DELETE
AS 
BEGIN
	IF EXISTS (SELECT *
			   FROM (SELECT *
					 FROM GIANGDAY D
					 EXCEPT
					 SELECT *
					 FROM deleted D) AS A
			   WHERE EXISTS (SELECT * 
							 FROM GIANGDAY GD 
							 WHERE A.MALOP = GD.MALOP AND A.MAMH NOT IN (SELECT MAMH_TRUOC
																		 FROM DIEUKIEN
																		 WHERE GD.MAMH = DIEUKIEN.MAMH)
							)
				)
	BEGIN
		PRINT 'LỖI: Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học xong những môn học phải học trước mới được học những môn liền sau).'
		ROLLBACK TRANSACTION 
	END
	ELSE
	BEGIN
		PRINT 'THÊM/SỬA GIANGDAY THÀNH CÔNG'
	END
END
GO

---Câu 23:
---			Them      Xoa     Sua
---GIANGDAY   +		   -	   +(MAGV) 
---GIAOVIEN	  -		   -	   +(MAKHOA)
CREATE TRIGGER tg_THEM_SUA_GIANGDAY_23 ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT *
			   FROM inserted I
			   WHERE MAMH NOT IN (SELECT MAMH
								  FROM GIAOVIEN GV, MONHOC MH
								  WHERE GV.MAGV = I.MAGV AND GV.MAKHOA = MH.MAKHOA)
				)
	BEGIN
		PRINT 'LỖI: Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách'
		ROLLBACK TRANSACTION 
	END
	ELSE
	BEGIN
		PRINT 'THÊM/SỬA GIANGDAY THÀNH CÔNG'
	END
END
GO

CREATE TRIGGER tg_SUA_GIAOVIEN_23 ON GIAOVIEN
FOR UPDATE
AS
BEGIN
	IF EXISTS (SELECT * 
			   FROM inserted I
			   WHERE EXISTS (SELECT * 
							 FROM GIANGDAY GD
							 WHERE I.MAGV = GD.MAGV AND GD.MAMH NOT IN (SELECT MAMH 
																		FROM MONHOC MH
																		WHERE I.MAKHOA = MH.MAKHOA)
							)
				)
	BEGIN
		PRINT 'LỖI: Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách'
		ROLLBACK TRANSACTION 
	END
	ELSE
	BEGIN
		PRINT 'SỬA GIAOVIEN THÀNH CÔNG'
	END
END
GO
					