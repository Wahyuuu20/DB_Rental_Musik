-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 16 Jul 2024 pada 13.22
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

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
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_hitung_luaskubus` (`sisi` INT) RETURNS INT(11)  BEGIN 
    RETURN (6 * sisi * sisi);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `customers`
--

CREATE TABLE `customers` (
  `id_customers` varchar(10) NOT NULL,
  `nama_customers` varchar(100) NOT NULL,
  `alamat` varchar(50) DEFAULT NULL,
  `no_telepon` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `customers`
--

INSERT INTO `customers` (`id_customers`, `nama_customers`, `alamat`, `no_telepon`) VALUES
('C001', 'Viky', 'Jl. Sambisari 48', '08519998081'),
('C002', 'Reza', 'Jl. Kenangan', '08998067560'),
('C003', 'Arya', 'Jl. Mid lane only', '082388890762'),
('C004', 'Nabil', 'Jl. pahlawan', '087665689908'),
('C005', 'Adib', 'Jl. samarinda 48', '084222335667');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kaset_musik`
--

CREATE TABLE `kaset_musik` (
  `id_kaset` varchar(10) NOT NULL,
  `judul` varchar(100) NOT NULL,
  `artis` varchar(50) NOT NULL,
  `genre_kaset` varchar(50) DEFAULT NULL,
  `stock` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kaset_musik`
--

INSERT INTO `kaset_musik` (`id_kaset`, `judul`, `artis`, `genre_kaset`, `stock`) VALUES
('K001', 'Say Hello', 'Hello', 'Pop', 5),
('K002', 'The Bip Hip', 'Slank', 'Rock', 5),
('K003', 'Mencoba Sukses Kembali', 'The Changcuters', 'Pop', 5),
('K004', 'Road To Abbey', 'J-Rocks', 'Rock', 5),
('K005', 'Perjalanan Karier Group Legendaris TH. 70-80', 'Koes Plus', 'Pop', 5);

-- --------------------------------------------------------

--
-- Struktur dari tabel `rental`
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
-- Dumping data untuk tabel `rental`
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
('R010', 'C005', 'K003', 'S002', '2024-07-01', '2024-07-09');

-- --------------------------------------------------------

--
-- Struktur dari tabel `staff`
--

CREATE TABLE `staff` (
  `id_staff` varchar(10) NOT NULL,
  `nama_staff` varchar(100) NOT NULL,
  `posisi_staff` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `staff`
--

INSERT INTO `staff` (`id_staff`, `nama_staff`, `posisi_staff`) VALUES
('S001', 'Restu Adji', 'Manager Toko 1'),
('S002', 'Wahyu', 'Manager Toko 2');

-- --------------------------------------------------------

--
-- Struktur dari tabel `staff_login`
--

CREATE TABLE `staff_login` (
  `id_staff_login` varchar(10) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `staff_login`
--

INSERT INTO `staff_login` (`id_staff_login`, `username`, `password`) VALUES
('S001', 'adji@sample.com', 'yomanasayatahu123'),
('S002', 'wahyu@sample.com', 'lokokgitu123');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id_customers`);

--
-- Indeks untuk tabel `kaset_musik`
--
ALTER TABLE `kaset_musik`
  ADD PRIMARY KEY (`id_kaset`);

--
-- Indeks untuk tabel `rental`
--
ALTER TABLE `rental`
  ADD PRIMARY KEY (`id_rental`),
  ADD KEY `customers_id` (`customers_id`),
  ADD KEY `kaset_musik_id` (`kaset_musik_id`),
  ADD KEY `staff_id` (`staff_id`);

--
-- Indeks untuk tabel `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id_staff`);

--
-- Indeks untuk tabel `staff_login`
--
ALTER TABLE `staff_login`
  ADD UNIQUE KEY `id_staff_login` (`id_staff_login`);

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `rental`
--
ALTER TABLE `rental`
  ADD CONSTRAINT `rental_ibfk_1` FOREIGN KEY (`customers_id`) REFERENCES `customers` (`id_customers`),
  ADD CONSTRAINT `rental_ibfk_2` FOREIGN KEY (`kaset_musik_id`) REFERENCES `kaset_musik` (`id_kaset`),
  ADD CONSTRAINT `rental_ibfk_3` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id_staff`);

--
-- Ketidakleluasaan untuk tabel `staff_login`
--
ALTER TABLE `staff_login`
  ADD CONSTRAINT `staff_login_ibfk_1` FOREIGN KEY (`id_staff_login`) REFERENCES `staff` (`id_staff`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
