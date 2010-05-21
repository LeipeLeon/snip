CREATE TABLE `urls` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `original` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `counter` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;