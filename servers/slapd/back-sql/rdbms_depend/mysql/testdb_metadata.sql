-- mappings 

-- objectClass mappings: these may be viewed as structuralObjectClass, the ones that are used to decide how to build an entry
--	id		a unique number identifying the objectClass
--	name		the name of the objectClass; it MUST match the name of an objectClass that is loaded in slapd's schema
--	keytbl		the name of the table that is referenced for the primary key of an entry
--	keycol		the name of the column in "keytbl" that contains the primary key of an entry; the pair "keytbl.keycol" uniquely identifies an entry of objectClass "id"
--	create_proc	a procedure to create the entry
--	delete_proc	a procedure to delete the entry; it takes "keytbl.keycol" of the row to be deleted
--	expect_return	a bitmap that marks whether create_proc (1) and delete_proc (2) return a value or not
INSERT INTO `ldap_oc_mappings` (id,name,keytbl,keycol,create_proc,delete_proc,expect_return)
VALUES ('1', 'inetOrgPerson', 'persons', 'id', 'SELECT create_person()', 'DELETE FROM persons WHERE id=?', 0);
INSERT INTO `ldap_oc_mappings` (id,name,keytbl,keycol,create_proc,delete_proc,expect_return)
VALUES ('2', 'document', 'documents', 'id', 'SELECT create_doc()', 'DELETE FROM documents WHERE id=?', 0);
INSERT INTO `ldap_oc_mappings` (id,name,keytbl,keycol,create_proc,delete_proc,expect_return)
VALUES ('3', 'organization', 'institutes', 'id', 'SELECT create_o()', 'DELETE FROM institutes WHERE id=?', 0);
INSERT INTO `ldap_oc_mappings` (id,name,keytbl,keycol,create_proc,delete_proc,expect_return)
VALUES ('4', 'referral', 'referrals', 'id', 'SELECT create_referral()', 'DELETE FROM referrals WHERE id=?', 0);
-- attributeType mappings: describe how an attributeType for a certain objectClass maps to the SQL data.
--	id		a unique number identifying the attribute	
--	oc_map_id	the value of "ldap_oc_mappings.id" that identifies the objectClass this attributeType is defined for
--	name		the name of the attributeType; it MUST match the name of an attributeType that is loaded in slapd's schema
--	sel_expr	the expression that is used to select this attribute (the "select <sel_expr> from ..." portion)
--	from_tbls	the expression that defines the table(s) this attribute is taken from (the "select ... from <from_tbls> where ..." portion)
--	join_where	the expression that defines the condition to select this attribute (the "select ... where <join_where> ..." portion)
--	add_proc	a procedure to insert the attribute; it takes the value of the attribute that is added, and the "keytbl.keycol" of the entry it is associated to
--	delete_proc	a procedure to delete the attribute; it takes the value of the attribute that is added, and the "keytbl.keycol" of the entry it is associated to
--	param_order	a mask that marks if the "keytbl.keycol" value comes before or after the value in add_proc (1) and delete_proc (2)
--	expect_return	a mask that marks whether add_proc (1) and delete_proc(2) are expected to return a value or not
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('1', '1', 'cn', 'concat(persons.name,\' \',persons.surname)', null, 'persons', null, 
	'SELECT update_person_cn(?,?)', 'SELECT 1 FROM persons WHERE persons.name=? AND persons.id=? AND 1=0', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('2', '1', 'telephoneNumber', 'phones.phone', null, 'persons,phones', 'phones.pers_id=persons.id', 
	'SELECT add_phone(?,?)', 'DELETE FROM phones WHERE phone=? AND pers_id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('3', '1', 'givenName', 'persons.name', null, 'persons', null, 
	'UPDATE persons SET name=? WHERE id=?', 'UPDATE persons SET name=\'\' WHERE (name=? OR name=\'\') AND id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('4', '1', 'sn', 'persons.surname', null, 'persons', null, 
	'UPDATE persons SET surname=? WHERE id=?', 'UPDATE persons SET surname=\'\' WHERE (surname=? OR surname=\'\') AND id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('5', '1', 'userPassword', 'persons.password', null, 'persons', 'persons.password IS NOT NULL', 
	'UPDATE persons SET password=? WHERE id=?', 'UPDATE persons SET password=NULL WHERE password=? AND id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('6', '1', 'seeAlso', 'seeAlso.dn', null, 'ldap_entries AS seeAlso,documents,authors_docs,persons', 
	'seeAlso.keyval=documents.id AND seeAlso.oc_map_id=2 AND authors_docs.doc_id=documents.id AND authors_docs.pers_id=persons.id', null, 'DELETE from authors_docs WHERE authors_docs.doc_id=(SELECT documents.id FROM documents,ldap_entries AS seeAlso WHERE seeAlso.keyval=documents.id AND seeAlso.oc_map_id=2 AND seeAlso.dn=?) AND authors_docs.pers_id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('7', '2', 'description', 'documents.abstract', null, 'documents', null, 
	'UPDATE documents SET abstract=? WHERE id=?', 'UPDATE documents SET abstract=\'\'\'\' WHERE abstract=? AND id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('8', '2', 'documentTitle', 'documents.title', null, 'documents', null, 
	'UPDATE documents SET title=? WHERE id=?', 'UPDATE documents SET title=\'\' WHERE title=? AND id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('9', '2', 'documentAuthor', 'documentAuthor.dn', null, 
	'ldap_entries AS documentAuthor,documents,authors_docs,persons', 'documentAuthor.keyval=persons.id AND documentAuthor.oc_map_id=1 AND authors_docs.doc_id=documents.id AND authors_docs.pers_id=persons.id', 'INSERT INTO authors_docs (pers_id,doc_id) VALUES ((SELECT ldap_entries.keyval FROM ldap_entries WHERE upper(?)=upper(ldap_entries.dn)),?)', 'DELETE FROM authors_docs WHERE authors_docs.pers_id=(SELECT ldap_entries.keyval FROM ldap_entries WHERE upper(?)=upper(ldap_entries.dn)) AND authors_docs.doc_id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('10', '2', 'documentIdentifier', 'concat(\'document \',documents.id)', null, 'documents', null, null, 
	'SELECT 1 FROM documents WHERE title=? AND id=? AND 1=0', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('11', '3', 'o', 'institutes.name', null, 'institutes', null, 
	'UPDATE institutes SET name=? WHERE id=?', 'UPDATE institutes SET name=\'\' WHERE name=? AND id=?', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('12', '3', 'dc', 'lower(institutes.name)', null, 
	'institutes,ldap_entries AS dcObject,ldap_entry_objclasses as auxObjectClass', 
	'institutes.id=dcObject.keyval AND dcObject.oc_map_id=3 AND dcObject.id=auxObjectClass.entry_id AND auxObjectClass.oc_name=\'dcObject\'', null, 'SELECT 1 FROM institutes WHERE lower(name)=? AND id=? and 1=0', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('13', '4', 'ou', 'referrals.name', null, 'referrals', null, 
	'UPDATE referrals SET name=? WHERE id=?', 'SELECT 1 FROM referrals WHERE name=? AND id=? and 1=0', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('14', '4', 'ref', 'referrals.url', null, 'referrals', null, 
	'UPDATE referrals SET url=? WHERE id=?', 'SELECT 1 FROM referrals WHERE url=? and id=? and 1=0', '3', '0');
INSERT INTO `ldap_attr_mappings` into ldap_attr_mappings (id,oc_map_id,name,sel_expr,from_tbls,join_where,add_proc,delete_proc,param_order,expect_return)
VALUES ('15', '1', 'userCertificate', 'certs.cert', null, 'persons,certs', 'certs.pers_id=persons.id', 
	null, null, '3', '0');

-- entries mapping: each entry must appear in this table, with a unique DN rooted at the database naming context
--	id		a unique number > 0 identifying the entry
--	dn		the DN of the entry, in "pretty" form
--	oc_map_id	the "ldap_oc_mappings.id" of the main objectClass of this entry (view it as the structuralObjectClass)
--	parent		the "ldap_entries.id" of the parent of this objectClass; 0 if it is the "suffix" of the database
--	keyval		the value of the "keytbl.keycol" defined for this objectClass
insert into ldap_entries (id,dn,oc_map_id,parent,keyval)
values (1,'dc=example,dc=com',3,0,1);

insert into ldap_entries (id,dn,oc_map_id,parent,keyval)
values (2,'cn=Mitya Kovalev,dc=example,dc=com',1,1,1);

insert into ldap_entries (id,dn,oc_map_id,parent,keyval)
values (3,'cn=Torvlobnor Puzdoy,dc=example,dc=com',1,1,2);

insert into ldap_entries (id,dn,oc_map_id,parent,keyval)
values (4,'cn=Akakiy Zinberstein,dc=example,dc=com',1,1,3);

insert into ldap_entries (id,dn,oc_map_id,parent,keyval)
values (5,'documentTitle=book1,dc=example,dc=com',2,1,1);

insert into ldap_entries (id,dn,oc_map_id,parent,keyval)
values (6,'documentTitle=book2,dc=example,dc=com',2,1,2);

insert into ldap_entries (id,dn,oc_map_id,parent,keyval)
values (7,'ou=Referral,dc=example,dc=com',4,1,1);

-- objectClass mapping: entries that have multiple objectClass instances are listed here with the objectClass name (view them as auxiliary objectClass)
--	entry_id	the "ldap_entries.id" of the entry this objectClass value must be added
--	oc_name		the name of the objectClass; it MUST match the name of an objectClass that is loaded in slapd's schema
insert into ldap_entry_objclasses (entry_id,oc_name)
values (1,'dcObject');

insert into ldap_entry_objclasses (entry_id,oc_name)
values (4,'pkiUser');

insert into ldap_entry_objclasses (entry_id,oc_name)
values (7,'extensibleObject');

----------------------------------
-- FUNCTIONS TO SUPPORT UPDATES AND DELETIONS
-- ----------------------------
-- Function structure for `add_phone`
-- ----------------------------
DROP FUNCTION IF EXISTS `add_phone`;
DELIMITER ;;
CREATE FUNCTION `add_phone`(`input_value` varchar(255),`input_id` int(11)) RETURNS int(11)
BEGIN
DECLARE return_value int(11);
SET return_value = 0;
insert into phones (phone,pers_id)
		values (input_value, input_id);
	select max(id) into return_value from phones;
	RETURN return_value;
END
;;
DELIMITER ;


-- ----------------------------
-- Function structure for `create_doc`
-- ----------------------------
DROP FUNCTION IF EXISTS `create_doc`;
DELIMITER ;;
CREATE FUNCTION `create_doc`() RETURNS int(11)
BEGIN
DECLARE return_value int(11);
SET return_value = 0;
	insert into documents(id,title,abstract) 
		values (null,'','');
	select max(id) into return_value from documents;
	RETURN return_value;
END
;;
DELIMITER ;

-- ----------------------------
-- Function structure for `create_o`
-- ----------------------------
DROP FUNCTION IF EXISTS `create_o`;
DELIMITER ;;
CREATE FUNCTION `create_o`() RETURNS int(11)
BEGIN
DECLARE return_value int(11);
SET return_value = 0;
	insert into institutes(id,name) 
		values (null,'');
	select max(id) into return_value from institutes;
	RETURN return_value;
END
;;
DELIMITER ;

-- ----------------------------
-- Function structure for `create_person`
-- ----------------------------
DROP FUNCTION IF EXISTS `create_person`;
DELIMITER ;;
CREATE FUNCTION `create_person`() RETURNS int(11)
BEGIN
DECLARE return_value int(11);
SET return_value = 0;
	insert into persons (id,name,surname) 
		values (null,'','');
	select max(id) into return_value from persons;
	RETURN return_value;
END
;;
DELIMITER ;

-- ----------------------------
-- Function structure for `create_referral`
-- ----------------------------
DROP FUNCTION IF EXISTS `create_referral`;
DELIMITER ;;
CREATE FUNCTION `create_referral`() RETURNS int(11)
BEGIN
DECLARE return_value int(11);
SET return_value = 0;
	insert into referrals(id,name, url) 
		values (null, '', '');
	select max(id) into return_value from referrals;
	RETURN return_value;
END
;;
DELIMITER ;

-- ----------------------------
-- Function structure for `update_person_cn`
-- ----------------------------
DROP FUNCTION IF EXISTS `update_person_cn`;
DELIMITER ;;
CREATE FUNCTION `update_person_cn`(`input_value` varchar(255),`input_id` int(11)) RETURNS int(11)
BEGIN
	#Routine body goes here...
	update persons set name = (
		select case 
			when position(' ' in input_value) = 0 then input_value 
			else substr($1, 1, position(' ' in input_value) - 1)
		end
	),surname = (
		select case 
			when position(' ' in input_value) = 0 then ''
			else substr(input_value, position(' ' in input_value) + 1) 
		end
	) where id = input_id;

	RETURN input_id;
END
;;
DELIMITER ;
