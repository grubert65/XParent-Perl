--dropdb xparent
--createdb --owner grubert --encoding 'UNICODE' xparent

/*-----------------------------------------
* label_path - stores unique label-paths 
* ID:   unique path id
* Len:  number of path edges
* Path: the path string
-----------------------------------------*/
drop table if exists LabelPath;
create table LabelPath (
    ID      serial primary key,
    len     integer not null,
    Path    text unique
);

/*-----------------------------------------
* DataPath - stored parent-child relationship
* Pid: id of parent node
* Cid: id of child node
* Cid could reference an element or a Data
-----------------------------------------*/
drop table if exists DataPath;
create table DataPath (
    Pid     integer references Element (Did),
    Cid     integer not null
);

/*-----------------------------------------
* element - stores XML elements
* PathID:   points to the unique path id
* Did:      unique element id
* Ordinal:  ordinal number
-----------------------------------------*/
drop table if exists Element;
create table Element (
    Did     serial primary key,
    PathID  integer references LabelPath (ID),
    Ordinal integer not null
);

/*-----------------------------------------
* Data
* Did:      unique data id
* PathID:   id of the element this data belongs to
* Ordinal:  attribute position of data 
* Value:    value
-----------------------------------------*/
drop table if exists Data;
create table Data (
    Did             integer references Element(Did),
    PathID          integer references LabelPath(ID),
    Ordinal         integer,
    Value           text
);

/*-----------------------------------------
* Ancestor - ancestor/descendant relationship
* Did:          id of parent node
* Ancestor:     unique id of element ancestor
* Level:        inheritance level
-----------------------------------------*/
drop table if exists Ancestor;
create table Ancestor (
    Did         integer references Element (Did),
    Ancestor    integer references Element(Did),
    Level   integer not null
);
