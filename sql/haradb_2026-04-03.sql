# ************************************************************
# Sequel Ace SQL dump
# バージョン 20099
#
# https://sequel-ace.com/
# https://github.com/Sequel-Ace/Sequel-Ace
#
# ホスト: tudmweb3.bestcloud.jp (MySQL 8.4.8)
# データベース: haradb
# 生成時間: 2026-04-03 07:28:30 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
SET NAMES utf8mb4;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE='NO_AUTO_VALUE_ON_ZERO', SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# テーブルのダンプ m_admin
# ------------------------------------------------------------

DROP TABLE IF EXISTS `m_admin`;

CREATE TABLE `m_admin` (
  `company_code` varchar(8) NOT NULL,
  `company_name` varchar(60) DEFAULT NULL,
  `center_name` varchar(60) DEFAULT NULL,
  `postal_code` varchar(8) DEFAULT NULL,
  `address1` varchar(100) DEFAULT NULL,
  `address2` varchar(100) DEFAULT NULL,
  `tel_no` varchar(20) DEFAULT NULL,
  `fax_no` varchar(20) DEFAULT NULL,
  `memo` varchar(100) DEFAULT NULL,
  `admin_password` varchar(60) DEFAULT NULL COMMENT '伝票確定等に必要なパスワード',
  `create_datetime` datetime DEFAULT NULL,
  `create_staff_code` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `create_staff_name` varchar(80) DEFAULT NULL,
  `update_datetime` datetime DEFAULT NULL,
  `update_staff_code` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `update_staff_name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`company_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

LOCK TABLES `m_admin` WRITE;
/*!40000 ALTER TABLE `m_admin` DISABLE KEYS */;

INSERT INTO `m_admin` (`company_code`, `company_name`, `center_name`, `postal_code`, `address1`, `address2`, `tel_no`, `fax_no`, `memo`, `admin_password`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	('001','株式会社テクニカル・ユニオン','TUセンター','104-0061','東京都中央区銀座8-12-8','PMO銀座八丁目９F','03-6264-2620','03-6264-2621','仮設定状態。','$2a$10$chehEmFWKQ3xmi0HYr/Ce.hGUzSkBOcuDIrmN3mEyK9zax41kmotC','2026-04-01 11:21:09','001','山田　太郎','2026-04-01 17:17:15','001','山田　太郎');

/*!40000 ALTER TABLE `m_admin` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ m_delivery_company
# ------------------------------------------------------------

DROP TABLE IF EXISTS `m_delivery_company`;

CREATE TABLE `m_delivery_company` (
  `delivery_company_code` char(5) COLLATE utf8mb4_general_ci NOT NULL,
  `delivery_company_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `use_flag` tinyint(1) NOT NULL DEFAULT '1',
  `create_datetime` datetime DEFAULT NULL,
  `create_staff_code` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_staff_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `update_datetime` datetime DEFAULT NULL,
  `update_staff_code` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `update_staff_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`delivery_company_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

LOCK TABLES `m_delivery_company` WRITE;
/*!40000 ALTER TABLE `m_delivery_company` DISABLE KEYS */;

INSERT INTO `m_delivery_company` (`delivery_company_code`, `delivery_company_name`, `note`, `use_flag`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	('DC001','ヤマト運輸',NULL,1,'2026-03-25 13:55:46','001','山田　太郎','2026-04-03 13:01:55','001','山田　太郎'),
	('DC002','佐川急便','m_supplier.delivery_company から移行',1,'2026-03-25 13:55:46','001','山田　太郎','2026-03-25 13:55:46',NULL,NULL),
	('DC003','西濃運輸','m_supplier.delivery_company から移行',1,'2026-03-25 13:55:46','001','山田　太郎','2026-03-25 13:55:46',NULL,NULL),
	('DC004','日本郵便',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC005','福山通運',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC006','日本通運',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC007','トナミ運輸',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC008','名鉄運輸',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC009','第一貨物',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC010','丸全昭和運輸',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC011','久留米運送',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC012','岡山県貨物運送',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC013','山九',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC014','鴻池運輸',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC015','センコー',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC016','日立物流',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC017','SGムービング',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC018','NXトランスポート',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC019','西濃エキスプレス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC020','JPロジスティクス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC021','関東配送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC022','関西物流サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC023','中部輸送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC024','東北物流ネットワーク',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC025','九州配送センター',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC026','冷蔵輸送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC027','冷凍食品配送',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC028','医薬品輸送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC029','精密機器輸送',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC030','危険物輸送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC031','長距離幹線輸送',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC032','中距離輸送便',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC033','短距離配送便',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC034','夜間配送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC035','早朝配送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC036','チャーター便サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC037','スポット配送便',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC038','定期便輸送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC039','企業専属配送',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC040','共同配送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC041','ラストワンマイル配送',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC042','EC配送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC043','店舗向け配送便',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC044','倉庫間輸送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC045','工場直送便',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC046','自社配送便',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC047','軽貨物配送サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC048','大型貨物輸送',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC049','混載便サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC050','直送便サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC051','物流アウトソーシング',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC052','サードパーティ物流',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC053','統合物流サービス',NULL,1,'2026-03-25 13:55:46','001','山田　太郎',NULL,NULL,NULL),
	('DC054','サンプリング物流',NULL,0,'2026-04-03 11:52:45','001','山田　太郎','2026-04-03 11:58:20','001','山田　太郎');

/*!40000 ALTER TABLE `m_delivery_company` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ m_item
# ------------------------------------------------------------

DROP TABLE IF EXISTS `m_item`;

CREATE TABLE `m_item` (
  `item_code` varchar(8) NOT NULL,
  `jan_code` varchar(16) NOT NULL,
  `item_name` varchar(200) DEFAULT NULL,
  `item_name_kana` varchar(60) DEFAULT NULL,
  `item_category` tinyint DEFAULT NULL COMMENT '1:食品　2:雑貨　3:日用品　4:衣料 5:小物',
  `gentanka` decimal(8,2) DEFAULT NULL,
  `baitanka` int DEFAULT NULL,
  `use_flag` tinyint DEFAULT NULL COMMENT '0:無効 1:有効 ',
  `memo` varchar(100) DEFAULT NULL,
  `create_datetime` datetime DEFAULT NULL,
  `create_staff_code` varchar(8) DEFAULT NULL,
  `create_staff_name` varchar(80) DEFAULT NULL,
  `update_datetime` datetime DEFAULT NULL,
  `update_staff_code` varchar(8) DEFAULT NULL,
  `update_staff_name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`item_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

LOCK TABLES `m_item` WRITE;
/*!40000 ALTER TABLE `m_item` DISABLE KEYS */;

INSERT INTO `m_item` (`item_code`, `jan_code`, `item_name`, `item_name_kana`, `item_category`, `gentanka`, `baitanka`, `use_flag`, `memo`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	('10000001','4900000000011','カップラーメン醤油','ｶｯﾌﾟﾗｰﾒﾝｼｮｳﾕ',1,120.00,180,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000002','4900000000028','カップラーメン味噌','ｶｯﾌﾟﾗｰﾒﾝﾐｿ',1,125.00,187,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000003','4900000000035','ペットボトル緑茶500ml','ﾘｮｸﾁｬ500ML',1,80.00,120,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000004','4900000000042','ミネラルウォーター500ml','ﾐﾈﾗﾙｳｫｰﾀｰ500ML',1,60.00,90,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000005','4900000000059','ポテトチップスうすしお','ﾎﾟﾃﾄﾁｯﾌﾟｽｳｽｼｵ',1,100.00,150,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000006','4900000000066','ボールペン黒','ﾎﾞｰﾙﾍﾟﾝｸﾛ',2,50.00,75,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000007','4900000000073','ノートB5','ﾉｰﾄB5',2,120.00,180,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000008','4900000000080','クリアファイルA4','ｸﾘｱﾌｧｲﾙA4',2,80.00,120,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000009','4900000000097','ティッシュペーパー5箱','ﾃｨｯｼｭﾍﾟｰﾊﾟｰ5ﾊﾟｯｸ',3,250.00,375,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000010','4900000000103','トイレットペーパー12ロール','ﾄｲﾚｯﾄﾍﾟｰﾊﾟｰ12R',3,300.00,450,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000011','4900000000110','Tシャツ白M','TｼｬﾂｼﾛM',4,500.00,750,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000012','4900000000127','靴下3足セット','ｸﾂｼﾀ3ｿｸ',4,300.00,450,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000013','4900000000134','ハンドタオル','ﾊﾝﾄﾞﾀｵﾙ',5,150.00,225,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000014','4900000000141','折りたたみ傘','ｵﾘﾀﾀﾐｶｻ',5,700.00,1050,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000015','4900000000158','エコバッグ','ｴｺﾊﾞｯｸﾞ',5,250.00,375,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000016','4900000000165','おにぎり鮭','ｵﾆｷﾞﾘｻｹ',1,110.00,165,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000017','4900000000172','おにぎり梅','ｵﾆｷﾞﾘｳﾒ',1,105.00,157,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000018','4900000000189','サンドイッチたまご','ｻﾝﾄﾞｲｯﾁﾀﾏｺﾞ',1,220.00,330,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000019','4900000000196','サンドイッチハム','ｻﾝﾄﾞｲｯﾁﾊﾑ',1,230.00,345,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000020','4900000000202','菓子パンあんぱん','ｶｼﾊﾟﾝｱﾝﾊﾟﾝ',1,98.00,147,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000021','4900000000219','菓子パンメロンパン','ｶｼﾊﾟﾝﾒﾛﾝﾊﾟﾝ',1,108.00,162,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000022','4900000000226','食パン8枚切','ｼｮｸﾊﾟﾝ8ﾏｲｷﾞﾘ',1,138.00,207,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000023','4900000000233','ロールパン6個入','ﾛｰﾙﾊﾟﾝ6ｺｲﾘ',1,148.00,222,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000024','4900000000240','牛乳1L','ｷﾞｭｳﾆｭｳ1L',1,188.00,282,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000025','4900000000257','ヨーグルトプレーン','ﾖｰｸﾞﾙﾄﾌﾟﾚｰﾝ',1,128.00,192,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000026','4900000000264','たまご10個入','ﾀﾏｺﾞ10ｺｲﾘ',1,218.00,327,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000027','4900000000271','納豆3個パック','ﾅｯﾄｳ3ｺﾊﾟｯｸ',1,88.00,132,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000028','4900000000288','豆腐もめん','ﾄｳﾌﾓﾒﾝ',1,58.00,87,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000029','4900000000295','豆腐きぬ','ﾄｳﾌｷﾇ',1,58.00,87,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000030','4900000000301','バナナ1袋','ﾊﾞﾅﾅ1ﾌｸﾛ',1,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000031','4900000000318','りんご1個','ﾘﾝｺﾞ1ｺ',1,128.00,192,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000032','4900000000325','みかん袋入','ﾐｶﾝﾌｸﾛｲﾘ',1,298.00,447,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000033','4900000000332','レタス1玉','ﾚﾀｽ1ﾀﾏ',1,158.00,237,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000034','4900000000349','キャベツ1玉','ｷｬﾍﾞﾂ1ﾀﾏ',1,178.00,267,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000035','4900000000356','きゅうり3本入','ｷｭｳﾘ3ﾎﾝｲﾘ',1,138.00,207,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000036','4900000000363','シャープペンシル0.5','ｼｬｰﾌﾟﾍﾟﾝｼﾙ0.5',2,98.00,147,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000037','4900000000370','消しゴム白','ｹｼｺﾞﾑｼﾛ',2,68.00,102,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000038','4900000000387','油性マーカー黒','ﾕｾｲﾏｰｶｰｸﾛ',2,120.00,180,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000039','4900000000394','蛍光ペン黄','ｹｲｺｳﾍﾟﾝｷ',2,88.00,132,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000040','4900000000400','付箋メモ','ﾌｾﾝﾒﾓ',2,148.00,222,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000041','4900000000417','コピー用紙A4 100枚','ｺﾋﾟｰﾖｳｼA4 100ﾏｲ',2,298.00,447,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000042','4900000000424','封筒長形3号','ﾌｳﾄｳﾅｶﾞｶﾀ3ｺﾞｳ',2,118.00,177,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000043','4900000000431','はさみ','ﾊｻﾐ',2,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000044','4900000000448','セロハンテープ','ｾﾛﾊﾝﾃｰﾌﾟ',2,108.00,162,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000046','4900000000462','電池単3 4本入','ﾃﾞﾝﾁﾀﾝ3 4ﾎﾝｲﾘ',2,298.00,447,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000047','4900000000479','延長コード1m','ｴﾝﾁｮｳｺｰﾄﾞ1M',2,780.00,1170,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000048','4900000000486','LED電球60形','LEDﾃﾞﾝｷｭｳ60ｶﾞﾀ',2,598.00,897,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000049','4900000000493','収納ボックスM','ｼｭｳﾉｳﾎﾞｯｸｽM',2,680.00,1020,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000050','4900000000509','収納ボックスL','ｼｭｳﾉｳﾎﾞｯｸｽL',2,880.00,1320,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000051','4900000000516','ハンガー5本組','ﾊﾝｶﾞｰ5ﾎﾝｸﾞﾐ',2,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000052','4900000000523','洗濯ばさみ20個入','ｾﾝﾀｸﾊﾞｻﾐ20ｺｲﾘ',2,158.00,237,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000053','4900000000530','卓上カレンダー','ﾀｸｼﾞｮｳｶﾚﾝﾀﾞｰ',2,348.00,522,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000054','4900000000547','壁掛けフック3個入','ｶﾍﾞｶｹﾌｯｸ3ｺｲﾘ',2,178.00,267,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000055','4900000000554','小物ケース','ｺﾓﾉｹｰｽ',2,220.00,330,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000056','4900000000561','台所用スポンジ3個入','ﾀﾞｲﾄﾞｺﾛﾖｳｽﾎﾟﾝｼﾞ3ｺｲﾘ',3,98.00,147,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000057','4900000000578','食器用洗剤詰替','ｼｮｯｷﾖｳｾﾝｻﾞｲﾂﾒｶｴ',3,168.00,252,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000058','4900000000585','浴室用洗剤','ﾖｸｼﾂﾖｳｾﾝｻﾞｲ',3,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000059','4900000000592','トイレ用洗剤','ﾄｲﾚﾖｳｾﾝｻﾞｲ',3,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000060','4900000000608','ハンドソープ本体','ﾊﾝﾄﾞｿｰﾌﾟﾎﾝﾀｲ',3,248.00,372,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000061','4900000000615','ハンドソープ詰替','ﾊﾝﾄﾞｿｰﾌﾟﾂﾒｶｴ',3,178.00,267,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000062','4900000000622','歯ブラシふつう','ﾊﾌﾞﾗｼﾌﾂｳ',3,98.00,147,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000063','4900000000639','歯みがき粉','ﾊﾐｶﾞｷｺ',3,138.00,207,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000064','4900000000646','シャンプー本体','ｼｬﾝﾌﾟｰﾎﾝﾀｲ',3,498.00,747,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000065','4900000000653','コンディショナー本体','ｺﾝﾃﾞｨｼｮﾅｰﾎﾝﾀｲ',3,498.00,747,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000066','4900000000660','ボディソープ本体','ﾎﾞﾃﾞｨｿｰﾌﾟﾎﾝﾀｲ',3,458.00,687,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000067','4900000000677','洗濯洗剤本体','ｾﾝﾀｸｾﾝｻﾞｲﾎﾝﾀｲ',3,398.00,597,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000068','4900000000684','柔軟剤本体','ｼﾞｭｳﾅﾝｻﾞｲﾎﾝﾀｲ',3,398.00,597,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000069','4900000000691','キッチンペーパー4ロール','ｷｯﾁﾝﾍﾟｰﾊﾟｰ4ﾛｰﾙ',3,248.00,372,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000070','4900000000707','ウェットティッシュ','ｳｪｯﾄﾃｨｯｼｭ',3,118.00,177,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000071','4900000000714','ゴミ袋45L 20枚','ｺﾞﾐﾌﾞｸﾛ45L 20ﾏｲ',3,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000072','4900000000721','ゴミ袋30L 20枚','ｺﾞﾐﾌﾞｸﾛ30L 20ﾏｲ',3,168.00,252,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000073','4900000000738','マスク7枚入','ﾏｽｸ7ﾏｲｲﾘ',3,138.00,207,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000074','4900000000745','綿棒100本入','ﾒﾝﾎﾞｳ100ﾎﾝｲﾘ',3,98.00,147,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000075','4900000000752','除菌シート','ｼﾞｮｷﾝｼｰﾄ',3,128.00,192,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000076','4900000000769','長袖Tシャツ白L','ﾅｶﾞｿﾃﾞTｼｬﾂｼﾛL',4,780.00,1170,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000077','4900000000776','長袖Tシャツ黒M','ﾅｶﾞｿﾃﾞTｼｬﾂｸﾛM',4,780.00,1170,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000078','4900000000783','ポロシャツ紺M','ﾎﾟﾛｼｬﾂｺﾝM',4,980.00,1470,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000079','4900000000790','ポロシャツ白L','ﾎﾟﾛｼｬﾂｼﾛL',4,980.00,1470,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000080','4900000000806','靴下黒25-27cm','ｸﾂｼﾀｸﾛ25-27CM',4,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000081','4900000000813','靴下白25-27cm','ｸﾂｼﾀｼﾛ25-27CM',4,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000082','4900000000820','インナーシャツM','ｲﾝﾅｰｼｬﾂM',4,498.00,747,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000083','4900000000837','インナーシャツL','ｲﾝﾅｰｼｬﾂL',4,498.00,747,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000084','4900000000844','作業手袋M','ｻｷﾞｮｳﾃﾌﾞｸﾛM',4,248.00,372,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000085','4900000000851','作業手袋L','ｻｷﾞｮｳﾃﾌﾞｸﾛL',4,248.00,372,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000086','4900000000868','ニット帽黒','ﾆｯﾄﾎﾞｳｸﾛ',4,680.00,1020,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000087','4900000000875','キャップ紺','ｷｬｯﾌﾟｺﾝ',4,780.00,1170,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000088','4900000000882','エプロン無地','ｴﾌﾟﾛﾝﾑｼﾞ',4,880.00,1320,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000089','4900000000899','レインコートM','ﾚｲﾝｺｰﾄM',4,1280.00,1920,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000090','4900000000905','レインコートL','ﾚｲﾝｺｰﾄL',4,1280.00,1920,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000091','4900000000912','パーカー灰M','ﾊﾟｰｶｰﾊｲM',4,1480.00,2220,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000092','4900000000929','パーカー黒L','ﾊﾟｰｶｰｸﾛL',4,1480.00,2220,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000093','4900000000936','スウェットパンツM','ｽｳｪｯﾄﾊﾟﾝﾂM',4,1280.00,1920,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000094','4900000000943','スウェットパンツL','ｽｳｪｯﾄﾊﾟﾝﾂL',4,1280.00,1920,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000095','4900000000950','ネックウォーマー','ﾈｯｸｳｫｰﾏｰ',4,580.00,870,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000096','4900000000967','キーケース黒','ｷｰｹｰｽｸﾛ',5,680.00,1020,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000097','4900000000974','小銭入れ茶','ｺｾﾞﾆｲﾚﾁｬ',5,880.00,1320,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000098','4900000000981','パスケース紺','ﾊﾟｽｹｰｽｺﾝ',5,780.00,1170,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000099','4900000000998','折りたたみ傘黒','ｵﾘﾀﾀﾐｶｻｸﾛ',5,980.00,1470,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000100','4900000001001','折りたたみ傘紺','ｵﾘﾀﾀﾐｶｻｺﾝ',5,980.00,1470,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000101','4900000001018','モバイルポーチ','ﾓﾊﾞｲﾙﾎﾟｰﾁ',5,780.00,1170,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000102','4900000001025','ハンドタオル青','ﾊﾝﾄﾞﾀｵﾙｱｵ',5,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000103','4900000001032','ハンドタオル白','ﾊﾝﾄﾞﾀｵﾙｼﾛ',5,198.00,297,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000104','4900000001049','ミニポーチ黒','ﾐﾆﾎﾟｰﾁｸﾛ',5,580.00,870,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000105','4900000001056','ミニポーチ灰','ﾐﾆﾎﾟｰﾁﾊｲ',5,580.00,870,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000106','4900000001063','カードケース','ｶｰﾄﾞｹｰｽ',5,680.00,1020,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000107','4900000001070','ネームホルダー','ﾈｰﾑﾎﾙﾀﾞｰ',5,298.00,447,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000108','4900000001087','ストラップ黒','ｽﾄﾗｯﾌﾟｸﾛ',5,248.00,372,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000109','4900000001094','ストラップ青','ｽﾄﾗｯﾌﾟｱｵ',5,248.00,372,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000110','4900000001100','エコバッグM','ｴｺﾊﾞｯｸﾞM',5,380.00,570,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000111','4900000001117','エコバッグL','ｴｺﾊﾞｯｸﾞL',5,480.00,720,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000112','4900000001124','保冷バッグS','ﾎﾚｲﾊﾞｯｸﾞS',5,680.00,1020,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000113','4900000001131','保冷バッグM','ﾎﾚｲﾊﾞｯｸﾞM',5,780.00,1170,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000114','4900000001148','保冷バッグL','ﾎﾚｲﾊﾞｯｸﾞL',5,880.00,1320,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10000115','4900000001155','携帯用ミラー','ｹｲﾀｲﾖｳﾐﾗｰ',5,320.00,480,NULL,'','2026-03-18 10:00:00','001','山田　太郎',NULL,NULL,NULL);

/*!40000 ALTER TABLE `m_item` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ m_prefecture
# ------------------------------------------------------------

DROP TABLE IF EXISTS `m_prefecture`;

CREATE TABLE `m_prefecture` (
  `prefecture_code` char(2) COLLATE utf8mb4_general_ci NOT NULL,
  `prefecture_name` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `use_flag` tinyint(1) NOT NULL DEFAULT '1',
  `create_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `create_staff_code` varchar(20) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'SYSTEM',
  `create_staff_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'SYSTEM',
  `update_datetime` datetime DEFAULT NULL,
  `update_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `update_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`prefecture_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

LOCK TABLES `m_prefecture` WRITE;
/*!40000 ALTER TABLE `m_prefecture` DISABLE KEYS */;

INSERT INTO `m_prefecture` (`prefecture_code`, `prefecture_name`, `note`, `use_flag`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	('01','北海道','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('02','青森県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('03','岩手県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('04','宮城県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('05','秋田県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('06','山形県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('07','福島県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('08','茨城県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('09','栃木県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('10','群馬県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('11','埼玉県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('12','千葉県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('13','東京都','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('14','神奈川県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('15','新潟県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('16','富山県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('17','石川県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('18','福井県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('19','山梨県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('20','長野県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('21','岐阜県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('22','静岡県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('23','愛知県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('24','三重県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('25','滋賀県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('26','京都府','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('27','大阪府','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('28','兵庫県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('29','奈良県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('30','和歌山県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('31','鳥取県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('32','島根県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('33','岡山県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('34','広島県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('35','山口県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('36','徳島県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('37','香川県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('38','愛媛県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('39','高知県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('40','福岡県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('41','佐賀県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('42','長崎県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('43','熊本県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('44','大分県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('45','宮崎県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('46','鹿児島県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('47','沖縄県','初期データ',1,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL);

/*!40000 ALTER TABLE `m_prefecture` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ m_staff
# ------------------------------------------------------------

DROP TABLE IF EXISTS `m_staff`;

CREATE TABLE `m_staff` (
  `staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ログイン用ユーザーコード',
  `staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'スタッフ名',
  `staff_kana` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'スタッフ名カナ',
  `login_password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'ログインパスワードハッシュ',
  `authority_level` tinyint DEFAULT NULL COMMENT '権限レベル 1:一般 2:責任者 9:管理者',
  `mail_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'メールアドレス',
  `tel_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '電話番号',
  `last_login_datetime` datetime DEFAULT NULL COMMENT '最終ログイン日時',
  `password_update_datetime` datetime DEFAULT NULL COMMENT 'パスワード更新日時',
  `use_flag` tinyint DEFAULT NULL COMMENT '使用可否 1:使用中 0:停止',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '備考',
  `create_datetime` datetime DEFAULT NULL COMMENT '登録日時',
  `create_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '登録者コード',
  `create_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '登録者名',
  `update_datetime` datetime DEFAULT NULL COMMENT '更新日時',
  `update_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新者コード',
  `update_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新者名',
  PRIMARY KEY (`staff_code`),
  UNIQUE KEY `uq_m_staff_staff_code` (`staff_code`),
  KEY `idx_m_staff_use_flag` (`use_flag`),
  KEY `idx_m_staff_authority_level` (`authority_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

LOCK TABLES `m_staff` WRITE;
/*!40000 ALTER TABLE `m_staff` DISABLE KEYS */;

INSERT INTO `m_staff` (`staff_code`, `staff_name`, `staff_kana`, `login_password_hash`, `authority_level`, `mail_address`, `tel_no`, `last_login_datetime`, `password_update_datetime`, `use_flag`, `note`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	('001','山田　太郎','ヤマダ タロウ','$2a$10$amxsxDduLJI0rmETfHIHv.xW1BgpluzOJWoS5OzkzNbrH13.k6Tqm',9,'yamada.taro@example.com','090-1111-0001',NULL,'2026-03-31 14:03:24',1,NULL,'2026-03-25 12:00:00','001','山田　太郎','2026-03-31 14:03:24','001','山田　太郎'),
	('002','佐藤　花子','サトウ ハナコ','$2a$10$AUsiFo8ktSTblf3HpigzDenTTNiDQVvmKlQ9F7YzBnoM7.kWX8ppW',1,'sato.hanako@example.com','090-1111-0002',NULL,'2026-03-31 14:45:18',1,NULL,'2026-03-25 12:00:00','001','山田　太郎','2026-03-31 14:45:18','001','山田　太郎'),
	('003','鈴木　一郎','スズキ イチロウ','ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',1,'suzuki.ichiro@example.com','090-1111-0003',NULL,NULL,1,NULL,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('004','高橋　美咲','タカハシ ミサキ','a3cc5fa667e54cc898143c572485b1a331882e6dd853c6f92181982a93e7b395',1,'takahashi.misaki@example.com','090-1111-0004',NULL,NULL,1,NULL,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('005','田中　健','タナカ ケン','a3cc5fa667e54cc898143c572485b1a331882e6dd853c6f92181982a93e7b395',1,'tanaka.ken@example.com','090-1111-0005',NULL,NULL,1,NULL,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('006','伊藤　優子','イトウ ユウコ','a3cc5fa667e54cc898143c572485b1a331882e6dd853c6f92181982a93e7b395',1,'ito.yuko@example.com','090-1111-0006',NULL,NULL,1,NULL,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('007','渡辺　翔','ワタナベ ショウ','a3cc5fa667e54cc898143c572485b1a331882e6dd853c6f92181982a93e7b395',1,'watanabe.sho@example.com','090-1111-0007',NULL,NULL,1,NULL,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('008','中村　葵','ナカムラ アオイ','a3cc5fa667e54cc898143c572485b1a331882e6dd853c6f92181982a93e7b395',1,'nakamura.aoi@example.com','090-1111-0008',NULL,NULL,1,NULL,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('009','小林　直樹','コバヤシ ナオキ','a3cc5fa667e54cc898143c572485b1a331882e6dd853c6f92181982a93e7b395',1,'kobayashi.naoki@example.com','090-1111-0009',NULL,NULL,1,NULL,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('010','加藤　真由','カトウ マユ','a3cc5fa667e54cc898143c572485b1a331882e6dd853c6f92181982a93e7b395',1,'kato.mayu@example.com','090-1111-0010',NULL,NULL,1,NULL,'2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('011','吉田　大輔','ヨシダ ダイスケ','a3cc5fa667e54cc898143c572485b1a331882e6dd853c6f92181982a93e7b395',1,'yoshida.daisuke@example.com','090-1111-0011',NULL,NULL,0,'退職想定サンプル','2026-03-25 12:00:00','001','山田　太郎',NULL,NULL,NULL),
	('012','山本　五郎','ﾔﾏﾓﾄ　ｺﾞﾛｳ','$2a$10$W6vYBsyEzHgfS8PbhdKUB.uWLYQruyB2vXXBHZGcVA0VAanHT2a6S',1,'yamamoto@example.com','123-4567-8901',NULL,'2026-03-31 14:45:53',1,'BCryptでのパスワード生成。','2026-03-31 14:06:57','001','山田　太郎','2026-03-31 14:45:53','001','山田　太郎'),
	('999','TUメンテナンス','ﾃｨｰﾕｰﾒﾝﾃﾅﾝｽ','389907E6847E5C1481A94269BB82A1BBACF89EFB2CF206CD8EB71815BB718CE1',9,'tu-admin@example.com','03-6264-2620',NULL,'2026-03-26 11:40:29',1,NULL,'2026-03-26 11:40:29','001','山田　太郎',NULL,NULL,NULL);

/*!40000 ALTER TABLE `m_staff` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ m_supplier
# ------------------------------------------------------------

DROP TABLE IF EXISTS `m_supplier`;

CREATE TABLE `m_supplier` (
  `supplier_id` int NOT NULL AUTO_INCREMENT COMMENT '取引先ID',
  `supplier_code` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '取引先コード',
  `supplier_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '取引先名',
  `supplier_name_kana` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '取引先名カナ',
  `zip_code` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '郵便番号',
  `prefecture_code` char(2) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `address1` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '住所1（市区町村）',
  `address2` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '住所2（番地・建物）',
  `tel` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '電話番号',
  `fax` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'FAX番号',
  `delivery_company_code` char(5) COLLATE utf8mb4_general_ci NOT NULL,
  `note` text COLLATE utf8mb4_general_ci COMMENT '備考',
  `use_flag` tinyint DEFAULT '1' COMMENT '使用フラグ（1:有効 0:無効）',
  `create_datetime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
  `create_staff_code` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '作成者コード',
  `create_staff_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '作成者名',
  `update_datetime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
  `update_staff_code` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新者コード',
  `update_staff_name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新者名',
  PRIMARY KEY (`supplier_id`),
  UNIQUE KEY `uq_supplier_code` (`supplier_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

LOCK TABLES `m_supplier` WRITE;
/*!40000 ALTER TABLE `m_supplier` DISABLE KEYS */;

INSERT INTO `m_supplier` (`supplier_id`, `supplier_code`, `supplier_name`, `supplier_name_kana`, `zip_code`, `prefecture_code`, `address1`, `address2`, `tel`, `fax`, `delivery_company_code`, `note`, `use_flag`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	(1,'SUP001','株式会社山田商事','カブシキガイシャヤマダショウジ','150-0001','13','渋谷区神宮前','1-1-1 山田ビル','03-1111-1111','03-1111-1112','DC002','メイン取引先',1,'2026-03-23 14:48:30','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(2,'SUP002','田中物流株式会社','タナカブツリュウカブシキガイシャ','530-0001','27','大阪市北区梅田','2-2-2 梅田タワー','06-2222-2222',NULL,'DC002','関西拠点',1,'2026-03-23 14:48:30','A001','山田　太郎','2026-03-31 09:36:29','A002','佐藤次郎'),
	(3,'SUP003','グリーンフーズ株式会社','グリーンフーズカブシキガイシャ','460-0001','23','名古屋市中区栄','3-3-3 栄ビル','052-333-3333','052-333-3334','DC002','食品系',1,'2026-03-23 14:48:30','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(4,'SUP004','株式会社北海商事','カブシキガイシャホッカイショウジ','060-0001','01','札幌市中央区','4-4-4','011-444-4444',NULL,'DC001','北海道エリア',1,'2026-03-23 14:48:30','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(5,'SUP005','九州トランスポート','キュウシュウトランスポート','810-0001','40','福岡市中央区天神','5-5-5 天神ビル','092-555-5555','092-555-5556','DC002','九州配送',1,'2026-03-23 14:48:30','A001','山田　太郎','2026-03-31 09:36:29','A003','鈴木一郎'),
	(6,'SUP006','サンプル商事6','サンプルショウジ6','100-0006','13','千代田区','6-6-6','03-1000-0006',NULL,'DC001','サンプル',0,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(7,'SUP007','サンプル商事7','サンプルショウジ7','100-0007','13','千代田区','7-7-7','03-1000-0007',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(8,'SUP008','サンプル商事8','サンプルショウジ8','100-0008','13','千代田区','8-8-8','03-1000-0008',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(9,'SUP009','サンプル商事9','サンプルショウジ9','100-0009','13','千代田区','9-9-9','03-1000-0009',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(10,'SUP010','サンプル商事10','サンプルショウジ10','100-0010','13','千代田区','10-10-10','03-1000-0010',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(11,'SUP011','サンプル物流11','サンプルブツリュウ11','530-0011','27','大阪市北区','11-11-11','06-2000-0011',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(12,'SUP012','サンプル物流12','サンプルブツリュウ12','530-0012','27','大阪市北区','12-12-12','06-2000-0012',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(13,'SUP013','サンプル物流13','サンプルブツリュウ13','530-0013','27','大阪市北区','13-13-13','06-2000-0013',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(14,'SUP014','サンプル物流14','サンプルブツリュウ14','530-0014','27','大阪市北区','14-14-14','06-2000-0014',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(15,'SUP015','サンプル物流15','サンプルブツリュウ15','530-0015','27','大阪市北区','15-15-15','06-2000-0015',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(16,'SUP016','グリーン商事16','グリーンショウジ16','460-0016','23','名古屋市中区','16-16-16','052-300-0016',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(17,'SUP017','グリーン商事17','グリーンショウジ17','460-0017','23','名古屋市中区','17-17-17','052-300-0017',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(18,'SUP018','グリーン商事18','グリーンショウジ18','460-0018','23','名古屋市中区','18-18-18','052-300-0018',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(19,'SUP019','グリーン商事19','グリーンショウジ19','460-0019','23','名古屋市中区','19-19-19','052-300-0019',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(20,'SUP020','グリーン商事20','グリーンショウジ20','460-0020','23','名古屋市中区','20-20-20','052-300-0020',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(21,'SUP021','北海物流21','ホッカイブツリュウ21','060-0021','01','札幌市','21-21-21','011-400-0021',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(22,'SUP022','北海物流22','ホッカイブツリュウ22','060-0022','01','札幌市','22-22-22','011-400-0022',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(23,'SUP023','北海物流23','ホッカイブツリュウ23','060-0023','01','札幌市','23-23-23','011-400-0023',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(24,'SUP024','北海物流24','ホッカイブツリュウ24','060-0024','01','札幌市','24-24-24','011-400-0024',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(25,'SUP025','北海物流25','ホッカイブツリュウ25','060-0025','01','札幌市','25-25-25','011-400-0025',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(26,'SUP026','九州配送26','キュウシュウハイソウ26','810-0026','40','福岡市','26-26-26','092-500-0026',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(27,'SUP027','九州配送27','キュウシュウハイソウ27','810-0027','40','福岡市','27-27-27','092-500-0027',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(28,'SUP028','九州配送28','キュウシュウハイソウ28','810-0028','40','福岡市','28-28-28','092-500-0028',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(29,'SUP029','九州配送29','キュウシュウハイソウ29','810-0029','40','福岡市','29-29-29','092-500-0029',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(30,'SUP030','九州配送30','キュウシュウハイソウ30','810-0030','40','福岡市','30-30-30','092-500-0030',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(31,'SUP031','関東商事31','カントウショウジ31','220-0031','14','横浜市','31-31-31','045-600-0031',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(32,'SUP032','関東商事32','カントウショウジ32','220-0032','14','横浜市','32-32-32','045-600-0032',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(33,'SUP033','関東商事33','カントウショウジ33','220-0033','14','横浜市','33-33-33','045-600-0033',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(34,'SUP034','関東商事34','カントウショウジ34','220-0034','14','横浜市','34-34-34','045-600-0034',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(35,'SUP035','関東商事35','カントウショウジ35','220-0035','14','横浜市','35-35-35','045-600-0035',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(36,'SUP036','東北物流36','トウホクブツリュウ36','980-0036','04','仙台市','36-36-36','022-700-0036',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(37,'SUP037','東北物流37','トウホクブツリュウ37','980-0037','04','仙台市','37-37-37','022-700-0037',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(38,'SUP038','東北物流38','トウホクブツリュウ38','980-0038','04','仙台市','38-38-38','022-700-0038',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(39,'SUP039','東北物流39','トウホクブツリュウ39','980-0039','04','仙台市','39-39-39','022-700-0039',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(40,'SUP040','東北物流40','トウホクブツリュウ40','980-0040','04','仙台市','40-40-40','022-700-0040',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(41,'SUP041','四国配送41','シコクハイソウ41','760-0041','37','高松市','41-41-41','087-800-0041',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(42,'SUP042','四国配送42','シコクハイソウ42','760-0042','37','高松市','42-42-42','087-800-0042',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(43,'SUP043','四国配送43','シコクハイソウ43','760-0043','37','高松市','43-43-43','087-800-0043',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(44,'SUP044','四国配送44','シコクハイソウ44','760-0044','37','高松市','44-44-44','087-800-0044',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(45,'SUP045','四国配送45','シコクハイソウ45','760-0045','37','高松市','45-45-45','087-800-0045',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A002','佐藤次郎','2026-03-25 14:36:55','A002','佐藤次郎'),
	(46,'SUP046','沖縄物流46','オキナワブツリュウ46','900-0046','47','那覇市','46-46-46','098-900-0046',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(47,'SUP047','沖縄物流47','オキナワブツリュウ47','900-0047','47','那覇市','47-47-47','098-900-0047',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(48,'SUP048','沖縄物流48','オキナワブツリュウ48','900-0048','47','那覇市','48-48-48','098-900-0048',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(49,'SUP049','沖縄物流49','オキナワブツリュウ49','900-0049','47','那覇市','49-49-49','098-900-0049',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A003','鈴木一郎','2026-03-25 14:36:55','A003','鈴木一郎'),
	(51,'SUP051','追加商事51','ツイカショウジ51','100-0051','13','中央区','51-51-51','03-9000-0051',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(52,'SUP052','追加商事52','ツイカショウジ52','100-0052','13','中央区','52-52-52','03-9000-0052',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(53,'SUP053','追加商事53','ツイカショウジ53','100-0053','13','中央区','53-53-53','03-9000-0053',NULL,'DC003','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(54,'SUP054','追加商事54','ツイカショウジ54','100-0054','13','中央区','54-54-54','03-9000-0054',NULL,'DC001','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎'),
	(55,'SUP055','追加商事55','ツイカショウジ55','100-0055','13','中央区','55-55-55','03-9000-0055',NULL,'DC002','サンプル',1,'2026-03-24 15:11:59','A001','山田　太郎','2026-03-31 09:36:29','A001','山田太郎');

/*!40000 ALTER TABLE `m_supplier` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ t_inventory
# ------------------------------------------------------------

DROP TABLE IF EXISTS `t_inventory`;

CREATE TABLE `t_inventory` (
  `item_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品コード',
  `current_qty` int NOT NULL DEFAULT '0' COMMENT '現在庫数',
  `safety_stock_qty` int NOT NULL DEFAULT '0' COMMENT '安全在庫数',
  `last_in_datetime` datetime DEFAULT NULL COMMENT '最終入庫日時',
  `last_out_datetime` datetime DEFAULT NULL COMMENT '最終出庫日時',
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '備考',
  `create_datetime` datetime NOT NULL,
  `create_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `create_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `update_datetime` datetime NOT NULL,
  `update_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `update_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`item_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

LOCK TABLES `t_inventory` WRITE;
/*!40000 ALTER TABLE `t_inventory` DISABLE KEYS */;

INSERT INTO `t_inventory` (`item_code`, `current_qty`, `safety_stock_qty`, `last_in_datetime`, `last_out_datetime`, `note`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	('10000013',4,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000014',1,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000015',4,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000022',5,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000023',6,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000024',9,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000033',7,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000034',8,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000035',8,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000041',4,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000042',6,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000043',6,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000048',2,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000049',2,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('10000050',1,0,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 11:23:10','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎');

/*!40000 ALTER TABLE `t_inventory` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ t_inventory_history
# ------------------------------------------------------------

DROP TABLE IF EXISTS `t_inventory_history`;

CREATE TABLE `t_inventory_history` (
  `history_no` bigint NOT NULL AUTO_INCREMENT,
  `item_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品コード',
  `change_type` tinyint NOT NULL COMMENT '1:加算 2:減算 3:直接設定',
  `before_qty` int NOT NULL DEFAULT '0' COMMENT '変更前在庫数',
  `change_qty` int NOT NULL DEFAULT '0' COMMENT '変更数量',
  `after_qty` int NOT NULL DEFAULT '0' COMMENT '変更後在庫数',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '理由',
  `create_datetime` datetime NOT NULL,
  `create_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `create_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`history_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

LOCK TABLES `t_inventory_history` WRITE;
/*!40000 ALTER TABLE `t_inventory_history` DISABLE KEYS */;

INSERT INTO `t_inventory_history` (`history_no`, `item_code`, `change_type`, `before_qty`, `change_qty`, `after_qty`, `reason`, `create_datetime`, `create_staff_code`, `create_staff_name`)
VALUES
	(1,'10000022',1,0,5,5,'一括確定（伝票番号:2604020001）','2026-04-02 11:23:10','001','山田　太郎'),
	(2,'10000023',1,0,6,6,'一括確定（伝票番号:2604020001）','2026-04-02 11:23:10','001','山田　太郎'),
	(3,'10000024',1,0,9,9,'一括確定（伝票番号:2604020001）','2026-04-02 11:23:10','001','山田　太郎'),
	(4,'10000041',1,0,4,4,'一括確定（伝票番号:2604020002）','2026-04-02 11:23:10','001','山田　太郎'),
	(5,'10000042',1,0,6,6,'一括確定（伝票番号:2604020002）','2026-04-02 11:23:10','001','山田　太郎'),
	(6,'10000043',1,0,6,6,'一括確定（伝票番号:2604020002）','2026-04-02 11:23:10','001','山田　太郎'),
	(7,'10000048',1,0,2,2,'一括確定（伝票番号:2604020003）','2026-04-02 11:23:10','001','山田　太郎'),
	(8,'10000049',1,0,2,2,'一括確定（伝票番号:2604020003）','2026-04-02 11:23:10','001','山田　太郎'),
	(9,'10000050',1,0,1,1,'一括確定（伝票番号:2604020003）','2026-04-02 11:23:10','001','山田　太郎'),
	(10,'10000033',1,0,7,7,'一括確定（伝票番号:2604020004）','2026-04-02 11:23:10','001','山田　太郎'),
	(11,'10000034',1,0,8,8,'一括確定（伝票番号:2604020004）','2026-04-02 11:23:10','001','山田　太郎'),
	(12,'10000035',1,0,8,8,'一括確定（伝票番号:2604020004）','2026-04-02 11:23:10','001','山田　太郎'),
	(13,'10000013',1,0,4,4,'一括確定（伝票番号:2604020005）','2026-04-02 11:23:10','001','山田　太郎'),
	(14,'10000014',1,0,1,1,'一括確定（伝票番号:2604020005）','2026-04-02 11:23:10','001','山田　太郎'),
	(15,'10000015',1,0,4,4,'一括確定（伝票番号:2604020005）','2026-04-02 11:23:10','001','山田　太郎');

/*!40000 ALTER TABLE `t_inventory_history` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ t_slip
# ------------------------------------------------------------

DROP TABLE IF EXISTS `t_slip`;

CREATE TABLE `t_slip` (
  `slip_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '伝票番号',
  `slip_date` date NOT NULL COMMENT '発注日',
  `supplier_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '取引先コード',
  `supplier_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '取引先名（履歴保持）',
  `delivery_date` date NOT NULL COMMENT '納品日',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1:登録 2:確定 3:削除',
  `total_qty` int DEFAULT '0' COMMENT '合計数量',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '合計金額',
  `fix_datetime` datetime DEFAULT NULL COMMENT '確定日時',
  `delete_datetime` datetime DEFAULT NULL COMMENT '削除日時',
  `memo` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '備考',
  `create_datetime` datetime DEFAULT NULL COMMENT '作成日時',
  `create_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作成者コード',
  `create_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作成者名',
  `update_datetime` datetime DEFAULT NULL COMMENT '更新日時',
  `update_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新者コード',
  `update_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新者名',
  PRIMARY KEY (`slip_no`),
  KEY `idx_supplier_code` (`supplier_code`),
  KEY `idx_slip_date` (`slip_date`),
  KEY `idx_delivery_date` (`delivery_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='伝票ヘッダ';

LOCK TABLES `t_slip` WRITE;
/*!40000 ALTER TABLE `t_slip` DISABLE KEYS */;

INSERT INTO `t_slip` (`slip_no`, `slip_date`, `supplier_code`, `supplier_name`, `delivery_date`, `status`, `total_qty`, `total_amount`, `fix_datetime`, `delete_datetime`, `memo`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	('2603010001','2026-04-01','SUP001','株式会社山田商事','2026-03-02',1,2,240.00,NULL,NULL,NULL,'2026-03-31 10:05:20','001','山田　太郎','2026-03-31 10:05:20','001','山田　太郎'),
	('2604010001','2026-04-01','SUP006','サンプル商事6','2026-04-02',1,11,1018.00,NULL,NULL,NULL,'2026-04-01 15:59:09','001','山田　太郎','2026-04-01 15:59:09','001','山田　太郎'),
	('2604010002','2026-04-01','SUP002','田中物流株式会社','2026-04-02',1,15,1350.00,NULL,NULL,NULL,'2026-04-01 09:10:00','001','山田　太郎','2026-04-01 09:10:00','001','山田　太郎'),
	('2604010003','2026-04-01','SUP003','グリーンフーズ株式会社','2026-04-02',1,12,1396.00,NULL,NULL,NULL,'2026-04-01 09:18:00','001','山田　太郎','2026-04-01 09:18:00','001','山田　太郎'),
	('2604010004','2026-04-01','SUP004','株式会社北海商事','2026-04-03',1,10,1340.00,'2026-04-01 11:05:00',NULL,NULL,'2026-04-01 09:32:00','002','佐藤次郎','2026-04-01 11:05:00','002','佐藤次郎'),
	('2604010005','2026-04-01','SUP005','九州トランスポート','2026-04-03',1,14,2480.00,NULL,NULL,NULL,'2026-04-01 10:01:00','003','鈴木一郎','2026-04-01 10:01:00','003','鈴木一郎'),
	('2604010006','2026-04-01','SUP006','サンプル商事6','2026-04-04',1,16,2156.00,'2026-04-01 14:20:00',NULL,NULL,'2026-04-01 10:20:00','001','山田　太郎','2026-04-01 14:20:00','001','山田　太郎'),
	('2604010007','2026-04-01','SUP001','株式会社山田商事','2026-04-04',1,10,1446.00,NULL,NULL,NULL,'2026-04-01 10:45:00','001','山田　太郎','2026-04-01 10:45:00','001','山田　太郎'),
	('2604010008','2026-04-01','SUP002','田中物流株式会社','2026-04-05',1,12,1574.00,NULL,NULL,NULL,'2026-04-01 11:02:00','002','佐藤次郎','2026-04-01 11:02:00','002','佐藤次郎'),
	('2604010009','2026-04-01','SUP003','グリーンフーズ株式会社','2026-04-05',1,8,1684.00,NULL,'2026-04-01 16:40:00','テスト削除','2026-04-01 11:30:00','001','山田　太郎','2026-04-01 16:40:00','001','山田　太郎'),
	('2604010010','2026-04-01','SUP004','株式会社北海商事','2026-04-06',1,18,1650.00,NULL,NULL,NULL,'2026-04-01 13:05:00','003','鈴木一郎','2026-04-01 13:05:00','003','鈴木一郎'),
	('2604010011','2026-04-01','SUP005','九州トランスポート','2026-04-06',1,9,1988.00,'2026-04-01 15:10:00',NULL,NULL,'2026-04-01 13:40:00','001','山田　太郎','2026-04-01 15:10:00','001','山田　太郎'),
	('2604020001','2026-04-02','SUP001','株式会社山田商事','2026-04-03',2,20,2205.00,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 09:00:00','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('2604020002','2026-04-02','SUP002','田中物流株式会社','2026-04-03',2,16,2592.00,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 09:20:00','002','佐藤次郎','2026-04-02 11:23:10','001','山田　太郎'),
	('2604020003','2026-04-02','SUP003','グリーンフーズ株式会社','2026-04-04',2,14,2716.00,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 10:00:00','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('2604020004','2026-04-02','SUP004','株式会社北海商事','2026-04-04',2,23,2169.00,'2026-04-02 11:23:10',NULL,NULL,'2026-04-02 10:40:00','003','鈴木一郎','2026-04-02 11:23:10','001','山田　太郎'),
	('2604020005','2026-04-02','SUP006','サンプル商事6','2026-04-05',2,10,2558.00,'2026-04-02 11:23:10','2026-04-02 17:10:00','キャンセル分','2026-04-02 11:10:00','001','山田　太郎','2026-04-02 11:23:10','001','山田　太郎'),
	('2604030001','2026-04-03','SUP001','株式会社山田商事','2026-04-04',1,14,1614.00,NULL,NULL,NULL,'2026-04-03 09:05:00','001','山田　太郎','2026-04-03 09:05:00','001','山田　太郎'),
	('2604030002','2026-04-03','SUP002','田中物流株式会社','2026-04-04',1,14,2264.00,'2026-04-03 12:45:00',NULL,NULL,'2026-04-03 09:30:00','002','佐藤次郎','2026-04-03 12:45:00','002','佐藤次郎'),
	('2604030003','2026-04-03','SUP003','グリーンフーズ株式会社','2026-04-05',1,16,2390.00,NULL,NULL,NULL,'2026-04-03 10:00:00','001','山田　太郎','2026-04-03 10:00:00','001','山田　太郎'),
	('2604030004','2026-04-03','SUP005','九州トランスポート','2026-04-05',1,10,2140.00,NULL,NULL,NULL,'2026-04-03 10:30:00','003','鈴木一郎','2026-04-03 10:30:00','003','鈴木一郎'),
	('2604030005','2026-04-03','SUP006','サンプル商事6','2026-04-06',1,13,2512.00,'2026-04-03 16:20:00',NULL,NULL,'2026-04-03 11:00:00','001','山田　太郎','2026-04-03 16:20:00','001','山田　太郎'),
	('S0000001','2026-04-01','SUP002','田中物流株式会社','2026-04-03',3,15,2100.00,NULL,NULL,NULL,'2026-03-01 10:00:00','001','山田　太郎','2026-04-02 16:46:47','001','山田　太郎'),
	('S0000002','2026-04-01','SUP010','サンプル商事10','2026-03-04',1,20,2000.00,NULL,NULL,NULL,'2026-03-02 10:00:00','002','佐藤次郎','2026-04-02 16:57:48','001','山田　太郎'),
	('S0000003','2026-04-01','SUP003','グリーンフーズ株式会社','2026-03-05',1,10,800.00,'2026-04-01 13:59:56',NULL,NULL,'2026-03-03 10:00:00','001','山田　太郎',NULL,NULL,NULL),
	('S0000004','2026-04-01','SUP004','株式会社北海商事','2026-03-06',1,12,1800.00,'2026-04-01 10:20:14',NULL,NULL,'2026-03-04 10:00:00','003','鈴木一郎',NULL,NULL,NULL),
	('S0000005','2026-04-01','SUP005','九州トランスポート','2026-03-07',1,18,7500.00,NULL,NULL,NULL,'2026-03-05 10:00:00','001','山田　太郎',NULL,NULL,NULL);

/*!40000 ALTER TABLE `t_slip` ENABLE KEYS */;
UNLOCK TABLES;


# テーブルのダンプ t_slip_detail
# ------------------------------------------------------------

DROP TABLE IF EXISTS `t_slip_detail`;

CREATE TABLE `t_slip_detail` (
  `slip_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '伝票番号',
  `line_no` int NOT NULL COMMENT '行番号',
  `item_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品コード',
  `jan_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'JANコード',
  `item_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '商品名（履歴保持用）',
  `qty` int DEFAULT NULL COMMENT '数量',
  `unit_price` decimal(10,2) DEFAULT NULL COMMENT '単価',
  `amount` decimal(12,2) GENERATED ALWAYS AS ((`qty` * `unit_price`)) STORED COMMENT '金額',
  `memo` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '明細備考',
  `create_datetime` datetime DEFAULT NULL COMMENT '作成日時',
  `create_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作成者コード',
  `create_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '作成者名',
  `update_datetime` datetime DEFAULT NULL COMMENT '更新日時',
  `update_staff_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新者コード',
  `update_staff_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '更新者名',
  PRIMARY KEY (`slip_no`,`line_no`),
  KEY `idx_item_code` (`item_code`),
  KEY `idx_jan_code` (`jan_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='伝票明細';

LOCK TABLES `t_slip_detail` WRITE;
/*!40000 ALTER TABLE `t_slip_detail` DISABLE KEYS */;

INSERT INTO `t_slip_detail` (`slip_no`, `line_no`, `item_code`, `jan_code`, `item_name`, `qty`, `unit_price`, `memo`, `create_datetime`, `create_staff_code`, `create_staff_name`, `update_datetime`, `update_staff_code`, `update_staff_name`)
VALUES
	('2603010001',1,'10000001','4900000000011','カップラーメン醤油',2,120.00,NULL,'2026-03-31 10:05:20','001','山田　太郎','2026-03-31 10:05:20','001','山田　太郎'),
	('2604010001',1,'10000056','4900000000561','台所用スポンジ3個入',5,98.00,NULL,'2026-04-01 15:59:09','001','山田　太郎','2026-04-01 15:59:09','001','山田　太郎'),
	('2604010001',2,'10000039','4900000000394','蛍光ペン黄',6,88.00,NULL,'2026-04-01 15:59:09','001','山田　太郎','2026-04-01 15:59:09','001','山田　太郎'),
	('2604010002',1,'10000003','4900000000035','ペットボトル緑茶500ml',8,120.00,NULL,'2026-04-01 09:10:00','001','山田　太郎','2026-04-01 09:10:00','001','山田　太郎'),
	('2604010002',2,'10000004','4900000000042','ミネラルウォーター500ml',7,90.00,NULL,'2026-04-01 09:10:00','001','山田　太郎','2026-04-01 09:10:00','001','山田　太郎'),
	('2604010003',1,'10000020','4900000000202','菓子パンあんぱん',4,147.00,NULL,'2026-04-01 09:18:00','001','山田　太郎','2026-04-01 09:18:00','001','山田　太郎'),
	('2604010003',2,'10000021','4900000000219','菓子パンメロンパン',8,162.00,NULL,'2026-04-01 09:18:00','001','山田　太郎','2026-04-01 09:18:00','001','山田　太郎'),
	('2604010004',1,'10000007','4900000000073','ノートB5',5,180.00,NULL,'2026-04-01 09:32:00','002','佐藤次郎','2026-04-01 09:32:00','002','佐藤次郎'),
	('2604010004',2,'10000008','4900000000080','クリアファイルA4',5,88.00,NULL,'2026-04-01 09:32:00','002','佐藤次郎','2026-04-01 09:32:00','002','佐藤次郎'),
	('2604010005',1,'10000011','4900000000110','Tシャツ白M',2,750.00,NULL,'2026-04-01 10:01:00','003','鈴木一郎','2026-04-01 10:01:00','003','鈴木一郎'),
	('2604010005',2,'10000012','4900000000127','靴下3足セット',2,490.00,NULL,'2026-04-01 10:01:00','003','鈴木一郎','2026-04-01 10:01:00','003','鈴木一郎'),
	('2604010006',1,'10000024','4900000000240','牛乳1L',6,282.00,NULL,'2026-04-01 10:20:00','001','山田　太郎','2026-04-01 10:20:00','001','山田　太郎'),
	('2604010006',2,'10000025','4900000000257','ヨーグルトプレーン',10,46.00,NULL,'2026-04-01 10:20:00','001','山田　太郎','2026-04-01 10:20:00','001','山田　太郎'),
	('2604010007',1,'10000036','4900000000363','シャープペンシル0.5',4,147.00,NULL,'2026-04-01 10:45:00','001','山田　太郎','2026-04-01 10:45:00','001','山田　太郎'),
	('2604010007',2,'10000039','4900000000394','蛍光ペン黄',6,143.00,NULL,'2026-04-01 10:45:00','001','山田　太郎','2026-04-01 10:45:00','001','山田　太郎'),
	('2604010008',1,'10000026','4900000000264','たまご10個入',5,327.00,NULL,'2026-04-01 11:02:00','002','佐藤次郎','2026-04-01 11:02:00','002','佐藤次郎'),
	('2604010008',2,'10000027','4900000000271','納豆3個パック',7,134.00,NULL,'2026-04-01 11:02:00','002','佐藤次郎','2026-04-01 11:02:00','002','佐藤次郎'),
	('2604010009',1,'10000046','4900000000462','電池単3 4本入',2,447.00,NULL,'2026-04-01 11:30:00','001','山田　太郎','2026-04-01 11:30:00','001','山田　太郎'),
	('2604010009',2,'10000047','4900000000479','延長コード1m',1,1170.00,NULL,'2026-04-01 11:30:00','001','山田　太郎','2026-04-01 11:30:00','001','山田　太郎'),
	('2604010009',3,'10000044','4900000000448','セロハンテープ',2,310.00,NULL,'2026-04-01 11:30:00','001','山田　太郎','2026-04-01 11:30:00','001','山田　太郎'),
	('2604010010',1,'10000016','4900000000165','おにぎり鮭',6,165.00,NULL,'2026-04-01 13:05:00','003','鈴木一郎','2026-04-01 13:05:00','003','鈴木一郎'),
	('2604010010',2,'10000017','4900000000172','おにぎり梅',6,110.00,NULL,'2026-04-01 13:05:00','003','鈴木一郎','2026-04-01 13:05:00','003','鈴木一郎'),
	('2604010010',3,'10000018','4900000000189','サンドイッチたまご',6,0.00,NULL,'2026-04-01 13:05:00','003','鈴木一郎','2026-04-01 13:05:00','003','鈴木一郎'),
	('2604010011',1,'10000030','4900000000301','バナナ1袋',3,297.00,NULL,'2026-04-01 13:40:00','001','山田　太郎','2026-04-01 13:40:00','001','山田　太郎'),
	('2604010011',2,'10000031','4900000000318','りんご1個',4,192.00,NULL,'2026-04-01 13:40:00','001','山田　太郎','2026-04-01 13:40:00','001','山田　太郎'),
	('2604010011',3,'10000032','4900000000325','みかん袋入',2,322.00,NULL,'2026-04-01 13:40:00','001','山田　太郎','2026-04-01 13:40:00','001','山田　太郎'),
	('2604020001',1,'10000022','4900000000226','食パン8枚切',5,207.00,NULL,'2026-04-02 09:00:00','001','山田　太郎','2026-04-02 09:00:00','001','山田　太郎'),
	('2604020001',2,'10000023','4900000000233','ロールパン6個入',6,222.00,NULL,'2026-04-02 09:00:00','001','山田　太郎','2026-04-02 09:00:00','001','山田　太郎'),
	('2604020001',3,'10000024','4900000000240','牛乳1L',9,93.00,NULL,'2026-04-02 09:00:00','001','山田　太郎','2026-04-02 09:00:00','001','山田　太郎'),
	('2604020002',1,'10000041','4900000000417','コピー用紙A4 100枚',4,447.00,NULL,'2026-04-02 09:20:00','002','佐藤次郎','2026-04-02 09:20:00','002','佐藤次郎'),
	('2604020002',2,'10000042','4900000000424','封筒長形3号',6,177.00,NULL,'2026-04-02 09:20:00','002','佐藤次郎','2026-04-02 09:20:00','002','佐藤次郎'),
	('2604020002',3,'10000043','4900000000431','はさみ',6,122.00,NULL,'2026-04-02 09:20:00','002','佐藤次郎','2026-04-02 09:20:00','002','佐藤次郎'),
	('2604020003',1,'10000048','4900000000486','LED電球60形',2,897.00,NULL,'2026-04-02 10:00:00','001','山田　太郎','2026-04-02 10:00:00','001','山田　太郎'),
	('2604020003',2,'10000049','4900000000493','収納ボックスM',2,1020.00,NULL,'2026-04-02 10:00:00','001','山田　太郎','2026-04-02 10:00:00','001','山田　太郎'),
	('2604020003',3,'10000050','4900000000509','収納ボックスL',1,682.00,NULL,'2026-04-02 10:00:00','001','山田　太郎','2026-04-02 10:00:00','001','山田　太郎'),
	('2604020004',1,'10000033','4900000000332','レタス1玉',7,237.00,NULL,'2026-04-02 10:40:00','003','鈴木一郎','2026-04-02 10:40:00','003','鈴木一郎'),
	('2604020004',2,'10000034','4900000000349','キャベツ1玉',8,267.00,NULL,'2026-04-02 10:40:00','003','鈴木一郎','2026-04-02 10:40:00','003','鈴木一郎'),
	('2604020004',3,'10000035','4900000000356','きゅうり3本入',8,45.00,NULL,'2026-04-02 10:40:00','003','鈴木一郎','2026-04-02 10:40:00','003','鈴木一郎'),
	('2604020005',1,'10000013','4900000000134','ハンドタオル',4,225.00,NULL,'2026-04-02 11:10:00','001','山田　太郎','2026-04-02 11:10:00','001','山田　太郎'),
	('2604020005',2,'10000014','4900000000141','折りたたみ傘',1,1050.00,NULL,'2026-04-02 11:10:00','001','山田　太郎','2026-04-02 11:10:00','001','山田　太郎'),
	('2604020005',3,'10000015','4900000000158','エコバッグ',4,152.00,NULL,'2026-04-02 11:10:00','001','山田　太郎','2026-04-02 11:10:00','001','山田　太郎'),
	('2604030001',1,'10000027','4900000000271','納豆3個パック',5,132.00,NULL,'2026-04-03 09:05:00','001','山田　太郎','2026-04-03 09:05:00','001','山田　太郎'),
	('2604030001',2,'10000028','4900000000288','豆腐もめん',4,87.00,NULL,'2026-04-03 09:05:00','001','山田　太郎','2026-04-03 09:05:00','001','山田　太郎'),
	('2604030001',3,'10000029','4900000000295','豆腐きぬ',5,120.00,NULL,'2026-04-03 09:05:00','001','山田　太郎','2026-04-03 09:05:00','001','山田　太郎'),
	('2604030002',1,'10000038','4900000000387','油性マーカー黒',6,180.00,NULL,'2026-04-03 09:30:00','002','佐藤次郎','2026-04-03 09:30:00','002','佐藤次郎'),
	('2604030002',2,'10000039','4900000000394','蛍光ペン黄',4,132.00,NULL,'2026-04-03 09:30:00','002','佐藤次郎','2026-04-03 09:30:00','002','佐藤次郎'),
	('2604030002',3,'10000040','4900000000400','付箋メモ',4,164.00,NULL,'2026-04-03 09:30:00','002','佐藤次郎','2026-04-03 09:30:00','002','佐藤次郎'),
	('2604030003',1,'10000001','4900000000011','カップラーメン醤油',6,180.00,NULL,'2026-04-03 10:00:00','001','山田　太郎','2026-04-03 10:00:00','001','山田　太郎'),
	('2604030003',2,'10000002','4900000000028','カップラーメン味噌',5,187.00,NULL,'2026-04-03 10:00:00','001','山田　太郎','2026-04-03 10:00:00','001','山田　太郎'),
	('2604030003',3,'10000005','4900000000059','ポテトチップスうすしお',5,75.00,NULL,'2026-04-03 10:00:00','001','山田　太郎','2026-04-03 10:00:00','001','山田　太郎'),
	('2604030004',1,'10000009','4900000000097','ティッシュペーパー5箱',3,375.00,NULL,'2026-04-03 10:30:00','003','鈴木一郎','2026-04-03 10:30:00','003','鈴木一郎'),
	('2604030004',2,'10000010','4900000000103','トイレットペーパー12ロール',2,450.00,NULL,'2026-04-03 10:30:00','003','鈴木一郎','2026-04-03 10:30:00','003','鈴木一郎'),
	('2604030004',3,'10000013','4900000000134','ハンドタオル',5,23.00,NULL,'2026-04-03 10:30:00','003','鈴木一郎','2026-04-03 10:30:00','003','鈴木一郎'),
	('2604030005',1,'10000046','4900000000462','電池単3 4本入',2,447.00,NULL,'2026-04-03 11:00:00','001','山田　太郎','2026-04-03 11:00:00','001','山田　太郎'),
	('2604030005',2,'10000048','4900000000486','LED電球60形',1,897.00,NULL,'2026-04-03 11:00:00','001','山田　太郎','2026-04-03 11:00:00','001','山田　太郎'),
	('2604030005',3,'10000049','4900000000493','収納ボックスM',1,718.00,NULL,'2026-04-03 11:00:00','001','山田　太郎','2026-04-03 11:00:00','001','山田　太郎'),
	('S0000001',1,'10000001','4900000000011','カップラーメン醤油',5,180.00,NULL,'2026-04-02 16:46:47','001','山田　太郎','2026-04-02 16:46:47','001','山田　太郎'),
	('S0000001',2,'10000002','4900000000028','カップラーメン味噌',10,120.00,NULL,'2026-04-02 16:46:47','001','山田　太郎','2026-04-02 16:46:47','001','山田　太郎'),
	('S0000002',1,'10000003','4900000000035','ペットボトル緑茶500ml',10,120.00,NULL,'2026-04-02 16:57:48','001','山田　太郎',NULL,NULL,NULL),
	('S0000002',2,'10000004','4900000000042','ミネラルウォーター500ml',10,80.00,NULL,'2026-04-02 16:57:48','001','山田　太郎',NULL,NULL,NULL),
	('S0000003',1,'10000005','4900000000059','ポテトチップスうすしお',5,150.00,NULL,'2026-03-03 10:00:00','001','山田太郎',NULL,NULL,NULL),
	('S0000003',2,'10000006','4900000000066','ボールペン黒',5,50.00,NULL,'2026-03-03 10:00:00','001','山田太郎',NULL,NULL,NULL),
	('S0000004',1,'10000007','4900000000073','ノートB5',6,180.00,NULL,'2026-03-04 10:00:00','003','鈴木一郎',NULL,NULL,NULL),
	('S0000004',2,'10000008','4900000000080','クリアファイルA4',6,120.00,NULL,'2026-03-04 10:00:00','003','鈴木一郎',NULL,NULL,NULL),
	('S0000005',1,'10000009','4900000000097','ティッシュペーパー5箱',8,375.00,NULL,'2026-03-30 14:57:06','001','山田太郎',NULL,NULL,NULL),
	('S0000005',2,'10000010','4900000000103','トイレットペーパー12ロール',10,450.00,NULL,'2026-03-30 14:57:06','001','山田太郎',NULL,NULL,NULL);

/*!40000 ALTER TABLE `t_slip_detail` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
