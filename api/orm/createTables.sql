-- userRegists
CREATE TABLE IF NOT EXISTS `userRegists` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `userName` varchar(255) DEFAULT NULL,
    `password` varchar(255) DEFAULT NULL,
    `verification` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- user
CREATE TABLE IF NOT EXISTS `users` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `userName` varchar(255) DEFAULT NULL,
    `password` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- device
CREATE TABLE IF NOT EXISTS `devices` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `model` varchar(255) DEFAULT NULL,
    `openUDID` varchar(255) DEFAULT NULL,
    `systemVersion` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- application
CREATE TABLE IF NOT EXISTS `applications` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `deviceId` varchar(255) DEFAULT NULL,
    `UUID` varchar(255) DEFAULT NULL,
    `bundleIdentifier` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;