-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 20, 2024 at 12:20 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rental_kaset/cd_musik`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_add_rental` (IN `p_rental_id` VARCHAR(20), IN `p_kaset_musik_id` VARCHAR(20), IN `p_customers_id` VARCHAR(20), IN `p_staff_id` VARCHAR(20), IN `p_tanggal_rental` DATE, IN `p_tanggal_kembali` DATE)   BEGIN
    DECLARE v_stock INT;

    -- Periksa stok kaset musik
    SELECT stock INTO v_stock
    FROM kaset_musik
    WHERE id_kaset = p_kaset_musik_id;

    -- Jika stok lebih dari 0, lanjutkan dengan penyewaan
    IF v_stock > 0 THEN
        -- Tambahkan transaksi penyewaan baru
        INSERT INTO rental (id_rental, kaset_musik_id, tanggal_rental)
        VALUES (p_rental_id, p_kaset_musik_id, CURDATE());

        -- Kurangi stok kaset musik
        UPDATE kaset_musik
        SET stock = stock - 1
        WHERE id_kaset = p_kaset_musik_id;

        -- Tampilkan pesan sukses
        SELECT 'Rental Berhasil Ditambahkan !!' AS message;
    ELSE
        -- Tampilkan pesan kesalahan jika stok tidak mencukupi
        SELECT 'Stock Habis, Makanya Kembalikan Cepat!!' AS message;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_stock_kaset` ()   BEGIN
    DECLARE hasil VARCHAR(255);

    -- Cek apakah ada kaset dengan stok lebih dari 0
    IF EXISTS (SELECT 1 FROM kaset_musik WHERE stock > 0) THEN
        SET hasil = 'Stock Kaset Masih Ada.';
    ELSE
        SET hasil = 'Stock Habis, Makanya Kembalikan Cepat!';
    END IF;

    -- Tampilkan hasil
    SELECT hasil AS message;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `add_rental` (`p_customers_id` VARCHAR(20), `p_kaset_musik_id` VARCHAR(20)) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE v_stock INT;
    DECLARE v_message VARCHAR(255);

    -- Periksa stok kaset musik
    SELECT stock INTO v_stock
    FROM kaset_musik
    WHERE id_kaset = p_kaset_musik_id;

    -- Jika stok lebih dari 0, lanjutkan dengan penyewaan
    IF v_stock > 0 THEN
        -- Tambahkan transaksi penyewaan baru
        INSERT INTO rental (id_rental, kaset_musik_id, tanggal_rental)
        VALUES (p_customers_id, p_kaset_musik_id, CURDATE());

        -- Kurangi stok kaset musik
        UPDATE kaset_musik
        SET stock = stock - 1
        WHERE id_kaset = p_kaset_musik_id;

        SET v_message = 'Berhasil Menambah Rental!!.';
    ELSE
        -- Jika stok tidak mencukupi, kembalikan pesan kesalahan
        SET v_message = 'Tidak Ada Stock Kaset!!.';
    END IF;

    RETURN v_message;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `cek_stock_kaset` () RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE hasil VARCHAR(255);

    -- Cek apakah ada kaset dengan stok lebih dari 0
    IF EXISTS (SELECT 1 FROM kaset_musik WHERE stock > 0) THEN
        SET hasil = 'Stock Kaset Masih Ada.';
    ELSE
        SET hasil = 'Stock Habis, Makanya Kembalikan Cepat!.';
    END IF;

    RETURN hasil;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_hitung_luaskubus` (`sisi` INT) RETURNS INT(11)  BEGIN 
    RETURN (6 * sisi * sisi);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `activity_log`
--

CREATE TABLE `activity_log` (
  `log_id` int(11) NOT NULL,
  `action_type` varchar(50) DEFAULT NULL,
  `action_description` varchar(255) DEFAULT NULL,
  `action_date` datetime DEFAULT current_timestamp(),
  `user_id` varchar(20) DEFAULT NULL,
  `kaset_id` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id_customers` varchar(10) NOT NULL,
  `nama_customers` varchar(100) NOT NULL,
  `alamat` varchar(50) DEFAULT NULL,
  `no_telepon` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id_customers`, `nama_customers`, `alamat`, `no_telepon`) VALUES
('C001', 'Viky', 'Jl. Sambisari 48', '08519998081'),
('C002', 'Reza', 'Jl. Kenangan', '08998067560'),
('C003', 'Arya', 'Jl. Mid lane only', '082388890762'),
('C004', 'Nabil', 'Jl. pahlawan', '087665689908'),
('C005', 'Adib', 'Jl. samarinda 48', '084222335667');

--
-- Triggers `customers`
--
DELIMITER $$
CREATE TRIGGER `after_update_customers` AFTER UPDATE ON `customers` FOR EACH ROW BEGIN
    DECLARE action_desc VARCHAR(255);

    -- Membuat deskripsi aksi
    SET action_desc = CONCAT('Customer dengan ID ', NEW.id_customers, 
                             ' diupdate. Nama dari ', OLD.nama_customers, 
                             ' menjadi ', NEW.nama_customers, 
                             ', alamat dari ', OLD.alamat, 
                             ' menjadi ', NEW.alamat);

    -- Tambahkan log aksi
    INSERT INTO activity_log (action_type, action_description, user_id, customer_id)
    VALUES ('UPDATE', action_desc, NEW.id_customers);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_customers` BEFORE UPDATE ON `customers` FOR EACH ROW BEGIN
    DECLARE action_desc VARCHAR(255);

    -- Membuat deskripsi aksi
    SET action_desc = CONCAT('Customer dengan ID ', OLD.id_customers, 
                             ' diupdate. Nama dari ', OLD.nama_customers, 
                             ' menjadi ', NEW.nama_customers, 
                             ', alamat dari ', OLD.alamat, 
                             ' menjadi ', NEW.alamat,
                            ', no_telepon dari ', OLD.no_telepon,
                            ' menjadi ', NEW.no_telepon);

    -- Tambahkan log aksi
    INSERT INTO activity_log (action_type, action_description, user_id, customer_id)
    VALUES ('UPDATE', action_desc, OLD.id_customers);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `frekuensi_kaset_musik`
-- (See below for the actual view)
--
CREATE TABLE `frekuensi_kaset_musik` (
`kaset_musik_id` varchar(100)
,`judul` varchar(100)
,`kaset_musik_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `frekuensi_rental`
-- (See below for the actual view)
--
CREATE TABLE `frekuensi_rental` (
`id_customers` varchar(10)
,`nama_customers` varchar(100)
,`rental_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `kaset_musik`
--

CREATE TABLE `kaset_musik` (
  `id_kaset` varchar(10) NOT NULL,
  `judul` varchar(100) NOT NULL,
  `artis` varchar(50) NOT NULL,
  `genre_kaset` varchar(50) DEFAULT NULL,
  `stock` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kaset_musik`
--

INSERT INTO `kaset_musik` (`id_kaset`, `judul`, `artis`, `genre_kaset`, `stock`) VALUES
('K001', 'Say Hello', 'Hello', 'Pop', 5),
('K002', 'The Bip Hip', 'Slank', 'Rock', 5),
('K003', 'Mencoba Sukses Kembali', 'The Changcuters', 'Pop', 5),
('K004', 'Road To Abbey', 'J-Rocks', 'Rock', 4),
('K005', 'Perjalanan Karier Group Legendaris TH. 70-80', 'Koes Plus', 'Pop', 5);

--
-- Triggers `kaset_musik`
--
DELIMITER $$
CREATE TRIGGER `before_update_kaset` BEFORE UPDATE ON `kaset_musik` FOR EACH ROW BEGIN
    DECLARE action_desc VARCHAR(255);

    -- Membuat deskripsi aksi
    SET action_desc = CONCAT('Stock kaset dengan ID ', OLD.id_kaset, 
                             ' berubah dari ', OLD.stock, 
                             ' menjadi ', NEW.stock);

    -- Tambahkan log aksi
    INSERT INTO activity_log (action_type, action_description, user_id, kaset_id)
    VALUES ('UPDATE', action_desc, NEW.id_kaset, OLD.id_kaset);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `kaset_musik_rental_counts`
-- (See below for the actual view)
--
CREATE TABLE `kaset_musik_rental_counts` (
`kaset_musik_id` varchar(100)
,`judul` varchar(100)
,`kaset_musik_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `rental`
--

CREATE TABLE `rental` (
  `id_rental` varchar(10) NOT NULL,
  `customers_id` varchar(100) DEFAULT NULL,
  `kaset_musik_id` varchar(100) DEFAULT NULL,
  `staff_id` varchar(100) DEFAULT NULL,
  `tanggal_rental` date DEFAULT NULL,
  `tanggal_kembali` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rental`
--

INSERT INTO `rental` (`id_rental`, `customers_id`, `kaset_musik_id`, `staff_id`, `tanggal_rental`, `tanggal_kembali`) VALUES
('R001', 'C001', 'K001', 'S001', '2024-07-10', '2024-07-17'),
('R002', 'C002', 'K002', 'S002', '2024-07-10', '2024-07-20'),
('R003', 'C003', 'K003', 'S001', '2024-07-11', '2024-07-18'),
('R004', 'C004', 'K004', 'S002', '2024-07-11', '2024-07-18'),
('R005', 'C005', 'K005', 'S001', '2024-07-11', '2024-07-21'),
('R006', 'C002', 'K003', 'S002', '2024-07-18', '2024-07-26'),
('R007', 'C002', 'K004', 'S002', '2024-07-18', '2024-07-26'),
('R008', 'C001', 'K005', 'S001', '2024-07-06', '2024-07-09'),
('R009', 'C005', 'K002', 'S002', '2024-07-01', '2024-07-09'),
('R010', 'C005', 'K003', 'S002', '2024-07-01', '2024-07-09'),
('R011', NULL, 'K004', NULL, '2024-07-16', NULL);

--
-- Triggers `rental`
--
DELIMITER $$
CREATE TRIGGER `after_delete_rental` AFTER DELETE ON `rental` FOR EACH ROW BEGIN
    DECLARE action_desc VARCHAR(255);

    -- Membuat deskripsi aksi
    SET action_desc = CONCAT('Rental dengan ID ', OLD.id_rental, 
                             ' dihapus. Penyewa: ', OLD.customers_id, 
                             ', Kaset: ', OLD.kaset_musik_id, 
                             ', Tanggal Sewa: ', OLD.tanggal_rental);

    -- Tambahkan log aksi
    INSERT INTO activity_log (action_type, action_description, user_id, rental_id)
    VALUES ('DELETE', action_desc, OLD.staff_id, OLD.id_rental);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_rental` AFTER INSERT ON `rental` FOR EACH ROW BEGIN
    DECLARE action_desc VARCHAR(255);

    -- Membuat deskripsi aksi
    SET action_desc = CONCAT('Rental baru ditambahkan dengan ID ', NEW.id_rental, 
                             '. Penyewa: ', NEW.customers_id, 
                             ', Kaset: ', NEW.kaset_musik_id, 
                             ', Tanggal Sewa: ', NEW.tanggal_rental);

    -- Tambahkan log aksi
    INSERT INTO activity_log (action_type, action_description, user_id, rental_id)
    VALUES ('INSERT', action_desc, NEW.staff_id, NEW.id_rental);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_rental` BEFORE DELETE ON `rental` FOR EACH ROW BEGIN
    DECLARE action_desc VARCHAR(255);

    -- Membuat deskripsi aksi
    SET action_desc = CONCAT('Rental dengan ID ', OLD.id_rental, 
                             ' dihapus. Penyewa: ', OLD.customers_id, 
                             ', Kaset: ', OLD.kaset_musik_id, 
                             ', Tanggal Sewa: ', OLD.tanggal_rental);

    -- Tambahkan log aksi
    INSERT INTO activity_log (action_type, action_description, user_id, rental_id)
    VALUES ('DELETE', action_desc, OLD.staff_id, OLD.id_rental);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_rental` BEFORE INSERT ON `rental` FOR EACH ROW BEGIN
    DECLARE v_stock INT;

    -- Mengambil stok kaset musik
    SELECT stock INTO v_stock
    FROM kaset_musik
    WHERE id_kaset = NEW.kaset_musik_id;

    -- Jika stok tidak mencukupi, batalkan insert
    IF v_stock <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stok tidak mencukupi untuk kaset yang diminta.';
    ELSE
        -- Tambahkan log aksi
        INSERT INTO activity_log (action_type, action_description, user_id, kaset_id)
        VALUES ('INSERT', 'Rental ditambahkan', NEW.staff_id, NEW.kaset_musik_id);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `id_staff` varchar(10) NOT NULL,
  `nama_staff` varchar(100) NOT NULL,
  `posisi_staff` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`id_staff`, `nama_staff`, `posisi_staff`) VALUES
('S001', 'Restu Adji', 'Manager Toko 1'),
('S002', 'Wahyu', 'Manager Toko 2');

-- --------------------------------------------------------

--
-- Table structure for table `staff_login`
--

CREATE TABLE `staff_login` (
  `id_staff_login` varchar(10) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staff_login`
--

INSERT INTO `staff_login` (`id_staff_login`, `username`, `password`) VALUES
('S001', 'adji@sample.com', 'yomanasayatahu123'),
('S002', 'wahyu@sample.com', 'lokokgitu123');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_frekuensi_rental`
-- (See below for the actual view)
--
CREATE TABLE `v_frekuensi_rental` (
`id_customers` varchar(10)
,`nama_customers` varchar(100)
,`rental_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Structure for view `frekuensi_kaset_musik`
--
DROP TABLE IF EXISTS `frekuensi_kaset_musik`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `frekuensi_kaset_musik`  AS SELECT `kaset_musik_rental_counts`.`kaset_musik_id` AS `kaset_musik_id`, `kaset_musik_rental_counts`.`judul` AS `judul`, `kaset_musik_rental_counts`.`kaset_musik_count` AS `kaset_musik_count` FROM `kaset_musik_rental_counts` WHERE `kaset_musik_rental_counts`.`kaset_musik_count` = (select max(`kaset_musik_rental_counts`.`kaset_musik_count`) from `kaset_musik_rental_counts`) ;

-- --------------------------------------------------------

--
-- Structure for view `frekuensi_rental`
--
DROP TABLE IF EXISTS `frekuensi_rental`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `frekuensi_rental`  AS SELECT `c`.`id_customers` AS `id_customers`, `c`.`nama_customers` AS `nama_customers`, `r`.`rental_count` AS `rental_count` FROM (`customers` `c` join (select `rental`.`customers_id` AS `customers_id`,count(0) AS `rental_count` from `rental` group by `rental`.`customers_id`) `r` on(`c`.`id_customers` = `r`.`customers_id`)) ORDER BY `r`.`rental_count` DESC LIMIT 0, 1 ;

-- --------------------------------------------------------

--
-- Structure for view `kaset_musik_rental_counts`
--
DROP TABLE IF EXISTS `kaset_musik_rental_counts`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `kaset_musik_rental_counts`  AS SELECT `r`.`kaset_musik_id` AS `kaset_musik_id`, `k`.`judul` AS `judul`, count(`r`.`kaset_musik_id`) AS `kaset_musik_count` FROM (`rental` `r` join `kaset_musik` `k` on(`r`.`kaset_musik_id` = `k`.`id_kaset`)) GROUP BY `r`.`kaset_musik_id`, `k`.`judul` ;

-- --------------------------------------------------------

--
-- Structure for view `v_frekuensi_rental`
--
DROP TABLE IF EXISTS `v_frekuensi_rental`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_frekuensi_rental`  AS SELECT `c`.`id_customers` AS `id_customers`, `c`.`nama_customers` AS `nama_customers`, `r`.`rental_count` AS `rental_count` FROM (`customers` `c` join (select `rental`.`customers_id` AS `customers_id`,count(0) AS `rental_count` from `rental` group by `rental`.`customers_id`) `r` on(`c`.`id_customers` = `r`.`customers_id`)) WHERE `r`.`rental_count` = (select max(`counts`.`rental_count`) from (select count(0) AS `rental_count` from `rental` group by `rental`.`customers_id`) `counts`) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_log`
--
ALTER TABLE `activity_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `kaset_id` (`kaset_id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id_customers`),
  ADD KEY `idx_customers_alamat` (`alamat`);

--
-- Indexes for table `kaset_musik`
--
ALTER TABLE `kaset_musik`
  ADD PRIMARY KEY (`id_kaset`),
  ADD KEY `idx_nama_kaset_musik` (`judul`);

--
-- Indexes for table `rental`
--
ALTER TABLE `rental`
  ADD PRIMARY KEY (`id_rental`),
  ADD KEY `staff_id` (`staff_id`),
  ADD KEY `idx_rental_customers_id` (`customers_id`),
  ADD KEY `idx_rental_customers` (`customers_id`),
  ADD KEY `idx_rental_kaset` (`kaset_musik_id`),
  ADD KEY `idx_rental_tanggal_rental` (`tanggal_rental`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id_staff`);

--
-- Indexes for table `staff_login`
--
ALTER TABLE `staff_login`
  ADD UNIQUE KEY `id_staff_login` (`id_staff_login`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_log`
--
ALTER TABLE `activity_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_log`
--
ALTER TABLE `activity_log`
  ADD CONSTRAINT `activity_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `staff` (`id_staff`),
  ADD CONSTRAINT `activity_log_ibfk_2` FOREIGN KEY (`kaset_id`) REFERENCES `kaset_musik` (`id_kaset`);

--
-- Constraints for table `rental`
--
ALTER TABLE `rental`
  ADD CONSTRAINT `rental_ibfk_1` FOREIGN KEY (`customers_id`) REFERENCES `customers` (`id_customers`),
  ADD CONSTRAINT `rental_ibfk_2` FOREIGN KEY (`kaset_musik_id`) REFERENCES `kaset_musik` (`id_kaset`),
  ADD CONSTRAINT `rental_ibfk_3` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id_staff`);

--
-- Constraints for table `staff_login`
--
ALTER TABLE `staff_login`
  ADD CONSTRAINT `staff_login_ibfk_1` FOREIGN KEY (`id_staff_login`) REFERENCES `staff` (`id_staff`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
