﻿USE QUANLIGIAOVU

--- III. Ngôn ngữ truy vấn dữ liệu
--- Câu 19:
SELECT TOP (1) WITH TIES MAKHOA, TENKHOA
FROM KHOA
ORDER BY NGTLAP
	
--- Câu 20:
SELECT HOCHAM, COUNT(HOCHAM) AS SOLUONG
FROM GIAOVIEN
WHERE HOCHAM IN ('GS', 'PGS')
GROUP BY HOCHAM

--- Câu 21:
SELECT K.MAKHOA, HOCVI, COUNT(HOCVI) AS SOLUONG
FROM GIAOVIEN GV RIGHT JOIN KHOA K ON GV.MAKHOA = K.MAKHOA 
GROUP BY K.MAKHOA, HOCVI
ORDER BY K.MAKHOA

--- Câu 22:
SELECT KQT.MAMH, KQUA, COUNT(KQT.MAHV) AS SOLUONG
FROM (
		SELECT MAHV, MAMH, MAX(LANTHI) AS MAXLANTHI
		FROM KETQUATHI
		GROUP BY MAHV, MAMH
		) AS TMP
		JOIN KETQUATHI KQT 
		ON TMP.MAHV = KQT.MAHV AND TMP.MAMH = KQT.MAMH AND TMP.MAXLANTHI = KQT.LANTHI
GROUP BY KQT.MAMH, KQUA
ORDER BY KQT.MAMH

--- Câu 23:
SELECT GV.MAGV, HOTEN
FROM GIAOVIEN GV JOIN LOP L ON GV.MAGV = L.MAGVCN 
				 JOIN GIANGDAY GD ON GD.MALOP = L.MALOP AND GD.MAGV = GV.MAGV

--- Câu 24:
SELECT HO +' '+ TEN AS HOTEN 
FROM HOCVIEN
WHERE MAHV IN (
	SELECT TOP(1) WITH TIES TRGLOP
	FROM LOP
	ORDER BY SISO DESC
)

--- Câu 25:
SELECT HO + ' '+ TEN AS HOTEN
FROM HOCVIEN 
WHERE MAHV IN (
				SELECT TRGLOP
				FROM LOP
				WHERE TRGLOP IN(
								SELECT KQT.MAHV
								FROM (
										SELECT MAHV, MAMH, MAX(LANTHI) AS MAXLANTHI
										FROM KETQUATHI
										GROUP BY MAHV, MAMH
										) AS TMP
										JOIN KETQUATHI KQT 
										ON TMP.MAHV = KQT.MAHV AND TMP.MAMH = KQT.MAMH AND TMP.MAXLANTHI = KQT.LANTHI		
								WHERE KQT.KQUA = 'Khong Dat'
								GROUP BY KQT.MAHV
								HAVING COUNT(KQT.MAMH) > 3
								)
				)

--- Câu 26:
SELECT HV.MAHV, HO + ' ' + TEN AS HOTEN
FROM (SELECT TOP(1) WITH TIES MAHV, COUNT(MAMH) AS SOLUONG
	  FROM KETQUATHI
	  WHERE DIEM BETWEEN 9 AND 10
	  GROUP BY MAHV
	  ORDER BY SOLUONG DESC
	  ) AS TMP
	  JOIN HOCVIEN HV ON TMP.MAHV = HV.MAHV

--- Câu 27:
SELECT MALOP, HV.MAHV, HO + ' ' + TEN AS HOTEN
FROM(			
	SELECT TMP1.MAHV
	FROM
		(
		SELECT MALOP, HV.MAHV, COUNT(MAMH) AS SOLUONG
		FROM KETQUATHI KQT JOIN HOCVIEN HV ON KQT.MAHV = HV.MAHV
		WHERE DIEM BETWEEN 9 AND 10
		GROUP BY MALOP, HV.MAHV
		) AS TMP1		
		JOIN
		(
		SELECT MALOP, MAX(SOLUONG) AS MAXSOLUONG
		FROM (
				SELECT MALOP, HV.MAHV, COUNT(MAMH) AS SOLUONG
				FROM KETQUATHI KQT JOIN HOCVIEN HV ON KQT.MAHV = HV.MAHV
				WHERE DIEM BETWEEN 9 AND 10
				GROUP BY MALOP, HV.MAHV
			 ) AS TMP
		GROUP BY MALOP
		) AS TMP2
		ON TMP1.MALOP = TMP2.MALOP AND TMP1.SOLUONG = TMP2.MAXSOLUONG
	) AS TMP3
	JOIN HOCVIEN HV ON TMP3.MAHV = HV.MAHV
ORDER BY MALOP 

---Câu 28:
SELECT NAM, HOCKY, MAGV, COUNT(MAMH) AS SOMON, COUNT(MALOP) AS SOLOP
FROM GIANGDAY
GROUP BY NAM, HOCKY, MAGV

---Câu 29:
SELECT TMP3.NAM, TMP3.HOCKY, TMP3.MAGV, HOTEN
FROM( 
	SELECT TMP2.NAM, TMP2.HOCKY, TMP2.MAGV
	FROM(
		SELECT NAM, HOCKY, MAX(SLGD) AS MAXSLGD
		FROM(
			 SELECT NAM, HOCKY, MAGV, COUNT(MALOP) + COUNT(MAMH) AS SLGD
			 FROM GIANGDAY
			 GROUP BY NAM, HOCKY, MAGV
			 ) AS TMP
		GROUP BY NAM, HOCKY
		) AS TMP1
		JOIN
		(SELECT NAM, HOCKY, MAGV, COUNT(MALOP) + COUNT(MAMH) AS SLGD
			 FROM GIANGDAY
			 GROUP BY NAM, HOCKY, MAGV
		) AS TMP2
		ON TMP1.NAM = TMP2.NAM AND TMP1.HOCKY = TMP2.HOCKY AND TMP1.MAXSLGD = TMP2.SLGD
	) AS TMP3 
	JOIN GIAOVIEN GV ON TMP3.MAGV = GV.MAGV


---Câu 30:
SELECT MH.MAMH, TENMH
FROM MONHOC MH JOIN (
					SELECT TOP(1) WITH TIES MAMH, COUNT(MAHV) AS SL
					FROM KETQUATHI
					WHERE LANTHI = 1 AND KQUA = 'Khong Dat'
					GROUP BY MAMH
					ORDER BY SL DESC
					) AS TMP ON MH.MAMH = TMP.MAMH


---Câu 31:
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (
				SELECT MAHV
				FROM KETQUATHI
				EXCEPT 
				(SELECT MAHV
				FROM (
					SELECT MAHV, COUNT(MAMH) AS SL
					FROM KETQUATHI
					WHERE LANTHI = 1 AND KQUA = 'Khong Dat'
					GROUP BY MAHV
					) AS TMP
				)
				)


---Câu 32:
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (
				SELECT MAHV
				FROM KETQUATHI
				EXCEPT 
				(SELECT MAHV
				FROM (
					SELECT MAHV, COUNT(MAMH) AS SL
					FROM (
								SELECT KQT.MAHV, KQT.MAMH, LANTHI, KQUA 
								FROM(
										SELECT MAHV, MAMH, MAX(LANTHI) AS MAXLANTHI
										FROM KETQUATHI
										GROUP BY MAHV, MAMH) AS TMP2
										JOIN
										KETQUATHI KQT ON KQT.MAHV = TMP2.MAHV AND KQT.MAMH = TMP2.MAMH AND KQT.LANTHI = TMP2.MAXLANTHI
									) AS TMP		
					WHERE KQUA = 'Khong Dat'
					GROUP BY MAHV
					) AS TMP2
				))


---Câu 33:
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (
				SELECT MAHV
				FROM(
					SELECT MAHV, COUNT(MAMH) AS SLMH
					FROM KETQUATHI
					GROUP BY MAHV
					INTERSECT
					SELECT MAHV, COUNT(MAMH) AS SLD
					FROM KETQUATHI
					WHERE LANTHI = 1 AND KQUA = 'Dat'
					GROUP BY MAHV
				) AS TMP
				)


---Câu 34:
SELECT MAHV, HO + ' ' + TEN AS HOTEN
FROM HOCVIEN
WHERE MAHV IN (SELECT MAHV 
			   FROM(
					SELECT MAHV, COUNT(MAMH) AS SLMH
					FROM(
						 SELECT MAHV, MAMH, MAX(LANTHI) AS MAXLANTHI
						 FROM KETQUATHI
						 GROUP BY MAHV, MAMH
						 ) AS TMP
					GROUP BY MAHV
					INTERSECT
					SELECT MAHV, COUNT(MAMH) AS SLD
					FROM (
							SELECT KQT.MAHV, KQT.MAMH, LANTHI, KQUA 
							FROM(
								 SELECT MAHV, MAMH, MAX(LANTHI) AS MAXLANTHI
								 FROM KETQUATHI
								 GROUP BY MAHV, MAMH) AS TMP2
								 JOIN
								 KETQUATHI KQT ON KQT.MAHV = TMP2.MAHV AND KQT.MAMH = TMP2.MAMH AND KQT.LANTHI = TMP2.MAXLANTHI
								) AS TMP		
						WHERE KQUA = 'Dat'
						GROUP BY MAHV
						) AS TMP
				)


---Câu 35:
SELECT D.MAMH, D.MAHV, HO + ' ' + TEN AS HOTEN
FROM
	(SELECT KQT.MAMH, MAX(DIEM) AS MAXDIEM
	FROM (
			SELECT MAHV, MAMH, MAX(LANTHI) AS MAXLANTHI
			FROM KETQUATHI
			GROUP BY MAHV, MAMH) AS A
			JOIN 
			KETQUATHI KQT ON KQT.MAMH = A.MAMH AND KQT.MAHV = A.MAHV AND KQT.LANTHI = A.MAXLANTHI
	GROUP BY KQT.MAMH) AS B
	JOIN 
	(SELECT KQT.MAMH, KQT.MAHV, KQT.DIEM
	FROM
		(SELECT MAHV, MAMH, MAX(LANTHI) AS MAXLANTHI
		FROM KETQUATHI
		GROUP BY MAHV, MAMH) AS C
		JOIN
		KETQUATHI KQT ON KQT.MAMH = C.MAMH AND KQT.MAHV = C.MAHV AND KQT.LANTHI = C.MAXLANTHI) AS D
	ON D.MAMH = B.MAMH AND D.DIEM = B.MAXDIEM
	JOIN 
	HOCVIEN HV ON D.MAHV = HV.MAHV



