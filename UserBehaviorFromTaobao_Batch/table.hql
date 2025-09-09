/*
说明：淘宝用户行为数据
来源：https://tianchi.aliyun.com/dataset/dataDetail?dataId=649&userId=1
大小：3.5 G
记录数：100,150,807
字段数：5
*/

-- 建表
DROP TABLE IF EXISTS user_behavior;
CREATE TABLE user_behavior (
    user_id VARCHAR(50) COMMENT '用户ID',
    item_id VARCHAR(50) COMMENT '商品ID',
    category_id VARCHAR(50) COMMENT '商品类目ID',
    behavior_type VARCHAR(10) COMMENT '行为类型，枚举类型，包括(pv, buy, cart, fav)',
    timestamp INT COMMENT '行为时间戳',
    datetime VARCHAR(20) COMMENT '行为时间'
);

-- 加载数据（MySQL 语法）
-- 注意：需要先将文件上传到MySQL服务器可访问的位置
LOAD DATA INFILE '/var/lib/mysql-files/UserBehavior.csv'
INTO TABLE user_behavior
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
(user_id, item_id, category_id, behavior_type, timestamp)
SET datetime = FROM_UNIXTIME(timestamp);


-- 查看数据
SELECT * FROM user_behavior LIMIT 10;

-- 查看数据量
SELECT COUNT(*) FROM user_behavior;
-- 一共100150807条数据

-- 数据清洗，去掉完全重复的数据
-- MySQL 不支持 INSERT OVERWRITE，改为创建临时表
CREATE TABLE temp_user_behavior AS
SELECT DISTINCT *
FROM user_behavior;

-- 查看清洗后的数据量
SELECT COUNT(*) FROM temp_user_behavior;
-- 清空原表数据
-- 一共100150758，所以数据是存在重复值的

-- 临时表直接更名
RENAME TABLE user_behavior TO old_user_behavior, 
             temp_user_behavior TO user_behavior;

DROP TABLE old_user_behavior;


-- 查看时间是否有异常值
SELECT DATE(datetime) AS day 
FROM user_behavior 
GROUP BY DATE(datetime) 
ORDER BY day;

-- 数据存在空值，数据清洗，去掉时间异常的数据
DELETE FROM user_behavior WHERE CAST(datetime AS DATE) NOT BETWEEN '2017-11-25' AND '2017-12-03';

-- 查看 behavior_type 是否有异常值
SELECT behavior_type 
FROM user_behavior 
GROUP BY behavior_type;

-- 清洗后的数据量,100095549
SELECT COUNT(1) FROM user_behavior;