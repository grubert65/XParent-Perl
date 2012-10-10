begin transaction; 

/*-----------------------------------------
* label_path - stores unique label-paths 
* ID:   unique path id
* Len:  number of path edges
* Path: the path string
-----------------------------------------*/
drop table if exists LabelPath;
create table LabelPath (
    ID      integer not null, 
    len     integer not null,
    Path    text,
    primary key (ID),
    unique (Path)
);

/*-----------------------------------------
* DataPath - stored parent-child relationship
* Pid: id of parent node
* Cid: id of child node

Cid could reference an element or a Data
-----------------------------------------*/
drop table if exists DataPath;
create table DataPath (
    Pid     integer not null,
    Cid     integer not null,
    primary key (Cid),
    foreign key(Pid) references Element(Did)
);

/*-----------------------------------------
* element - stores XML elements
* PathID:   points to the unique path id
* Did:      unique element id
* Ordinal:  ordinal number
-----------------------------------------*/
drop table if exists Element;
create table Element (
    Did     integer primary key not null,
    PathID  integer not null,
    Ordinal integer not null,
    foreign key(PathID) references LabelPath(ID)
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
    Did             integer not null, 
    PathID          integer not null,
    Ordinal         integer,
    Value           text,
    foreign key(Did) references Element(Did),
    foreign key(PathID) references LabelPath(ID)
);

commit;
