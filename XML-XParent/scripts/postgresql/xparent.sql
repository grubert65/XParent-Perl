--dropdb xparent
--createdb --owner grubert --encoding 'UNICODE' xparent

drop table if exists DataPath;
drop table if exists Data;
drop table if exists Element;
drop table if exists LabelPath;

/*-----------------------------------------
* label_path - stores unique label-paths 
* ID:   unique path id
* Len:  number of path edges
* Path: the path string
-----------------------------------------*/
create table LabelPath (
    ID      serial primary key,
    len     integer not null,
    Path    text unique
);
 
/*-----------------------------------------
* element - stores XML elements
* PathID:   points to the unique path id
* Did:      unique element id
* Ordinal:  ordinal number
-----------------------------------------*/
create table Element (
    Did     serial primary key,
    PathID  integer references LabelPath (ID),
    Ordinal integer not null
);

/*-----------------------------------------
* DataPath - stored parent-child relationship
* Pid: id of parent node
* Cid: id of child node
* Cid could reference an element or a Data
-----------------------------------------*/
create table DataPath (
    Pid     integer references Element (Did),
    Cid     integer not null
);

/*-----------------------------------------
* Data
* Did:      unique data id
* PathID:   id of the element this data belongs to
* Ordinal:  attribute position of data 
* Value:    value
-----------------------------------------*/
create table Data (
    Did             integer references Element(Did),
    PathID          integer references LabelPath(ID),
    Ordinal         integer,
    Value           text
);

CREATE INDEX LabelPath_Path ON LabelPath (Path);
CREATE INDEX Element_PathID ON Element (PathID);
CREATE INDEX DataPath_Cid ON DataPath (Cid);
CREATE INDEX DataPath_Pid ON DataPath (Pid);
CREATE INDEX Data_Did ON Data (Did);
