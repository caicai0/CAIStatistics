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
    `deviceToken` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- userApplication
CREATE TABLE IF NOT EXISTS `userApplications` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `userId` int(11) DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `platform` varchar(255) DEFAULT NULL,
    `bundleIdentifier` varchar(255) DEFAULT NULL,
    `description` varchar(255) DEFAULT NULL,
    `selector` varchar(255) DEFAULT NULL,
    `keyPath` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- baseInfo
CREATE TABLE IF NOT EXISTS `baseInfos` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `userApplicationId` int(11) DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `classPath` varchar(255) DEFAULT NULL,
    `selector` varchar(255) DEFAULT NULL,
    `keyPath` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- applicationBaseInfo
CREATE TABLE IF NOT EXISTS `applicationBaseInfos` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `applicationId` int(11) DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `value` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- plan
CREATE TABLE IF NOT EXISTS `plans` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `userApplicationId` int(11) DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `type` int DEFAULT 0,
    `classPath` varchar(255) DEFAULT NULL,
    `selector` varchar(255) DEFAULT NULL,
    `keyPath` varchar(255) DEFAULT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 对于每一个应用建立对应的日志数据表 bundleIdentifier_index  应用修改bundleIdentifier 后删除无用表 创建新表

-- log
CREATE TABLE IF NOT EXISTS `logs_bundleIdentifier_indexs` (
    `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `userApplicationId` int(11) DEFAULT NULL,
    `name` varchar(255) DEFAULT NULL,
    `values` varchar(255) DEFAULT NULL,
    `timeStamp` datetime NOT NULL,
    `createdAt` datetime NOT NULL,
    `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


