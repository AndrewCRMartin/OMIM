DROP VIEW  sws_mutant;
DROP TABLE swsomim     CASCADE;
DROP TABLE omim_mutant CASCADE;
DROP TABLE omim_description CASCADE;

CREATE TABLE swsomim
        ( ac VARCHAR(8),
          omim VARCHAR(6)
        );
CREATE TABLE omim_mutant
        ( omim   VARCHAR(6),
          record CHAR(4),
          native CHAR(3),
          resnum_orig INT,
          resnum INT,
          mutant CHAR(3),
          valid  CHAR(1)
        );
CREATE TABLE omim_description
        ( omim   VARCHAR(6),
          record CHAR(4),
          descrip TEXT,
          PRIMARY KEY (omim, record)
        );
CREATE INDEX swsomim_ac_idx   ON swsomim (ac);
CREATE INDEX swsomim_omim_idx ON swsomim (omim);
CREATE INDEX omimmut_omim_idx ON omim_mutant (omim);
CREATE INDEX omimmut_omim_rec_idx ON omim_mutant (omim, record);


CREATE VIEW sws_mutant AS
        SELECT s.ac, o.omim, o.record, o.native, o.resnum_orig, o.resnum, o.mutant, o.valid
        FROM swsomim s, omim_mutant o
        WHERE s.omim = o.omim;

GRANT SELECT ON omim_description TO PUBLIC;
GRANT SELECT ON omim_mutant      TO PUBLIC;
GRANT SELECT ON sws_mutant       TO PUBLIC;
GRANT SELECT ON swsomim          TO PUBLIC;
