bash <<'SENSE_BOOTSTRAP'
set -euo pipefail
set -C

parent='sense-ontology'
target='sense-ontology/getting-started'
if [[ -L "$parent" || ( -e "$parent" && ! -d "$parent" ) ]]; then
  printf '%s\n' 'Refusing setup: sense-ontology must be a real directory, not a file or symlink.' >&2
  exit 1
fi
if [[ ! -d "$parent" ]]; then
  mkdir -- "$parent"
fi
cd -- "$parent"
if ! mkdir -- getting-started; then
  printf '%s\n' 'Refusing setup: sense-ontology/getting-started already exists (including a symlink), or cannot be created. Nothing was overwritten.' >&2
  exit 1
fi
trap 'status=$?; if [[ "$status" -ne 0 ]]; then printf "%s\n" "Setup stopped. Files already written in $target are left intact for inspection; nothing is removed. Re-running refuses this existing target." >&2; fi; exit "$status"' EXIT
cd -- getting-started
mkdir -- sql eval

cat > 'sql/01_setup.sql' <<'SENSE_FILE_SQL_01_SETUP_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- Setup: database, schemas, and warehouse for the Cortex Sense + Business Ontology quickstart
CREATE DATABASE IF NOT EXISTS SENSE_ONTOLOGY_QS;
CREATE SCHEMA IF NOT EXISTS SENSE_ONTOLOGY_QS.RAW;
CREATE SCHEMA IF NOT EXISTS SENSE_ONTOLOGY_QS.SAP;
CREATE WAREHOUSE IF NOT EXISTS SENSE_ONTOLOGY_QS_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

USE WAREHOUSE SENSE_ONTOLOGY_QS_WH;
SENSE_FILE_SQL_01_SETUP_SQL

cat > 'sql/02_raw_data.sql' <<'SENSE_FILE_SQL_02_RAW_DATA_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- =====================================================
-- RAW: Enterprise SAP-coded tables
-- Self-contained script: CREATE + INSERT for all tables
-- Realistic SAP column names (LIFNR, MAKTX, MATKL etc.)
-- This simulates what a real SAP extraction looks like.
-- =====================================================

USE DATABASE SENSE_ONTOLOGY_QS;
USE SCHEMA RAW;
USE WAREHOUSE SENSE_ONTOLOGY_QS_WH;

-- =============================================================================
-- MASTER DATA
-- =============================================================================

-- =====================================================
-- LFA1: Vendor Master
-- =====================================================
CREATE OR REPLACE TABLE LFA1 (
    LIFNR VARCHAR(10) NOT NULL PRIMARY KEY, -- Vendor number
    NAME1 VARCHAR(100),                     -- Vendor name
    ORT01 VARCHAR(50),                      -- City
    LAND1 VARCHAR(5),                       -- Country code
    STCD1 VARCHAR(30),                      -- Tax ID
    KRAUS VARCHAR(15),                      -- DUNS number (SAP uses KRAUS field)
    KTOKK VARCHAR(10),                      -- Account group (ZSTR=Strategic, ZSTD=Standard, ZPRB=Probationary)
    ZTERM VARCHAR(10)                       -- Payment terms
);

INSERT INTO LFA1 VALUES ('V10045', 'SHENZHEN ELECTRONICS CO. LTD', 'Shenzhen', 'CN', '91440300MA5FPQG72B', '54-138-7209', 'ZSTR', 'NET45');
INSERT INTO LFA1 VALUES ('V10078', 'PACIFIC METALS CORPORATION', 'Long Beach', 'US', '95-4821073', '07-823-6541', 'ZSTD', 'NET30');
INSERT INTO LFA1 VALUES ('V10089', 'ADVANCED SILICON SOLUTIONS INC.', 'Santa Clara', 'US', '77-3920184', '15-738-2904', 'ZSTR', 'NET45');
INSERT INTO LFA1 VALUES ('V10098', 'TOKYO SENSOR TECHNOLOGIES K.K.', 'Tokyo', 'JP', 'JP5010401098234', '71-385-6249', 'ZSTD', 'NET45');
INSERT INTO LFA1 VALUES ('V10102', 'RHINE CHEMICAL GMBH', 'Ludwigshafen', 'DE', 'DE283741956', '31-592-4780', 'ZSTR', 'NET30');
INSERT INTO LFA1 VALUES ('V10134', 'BAYERN KUNSTSTOFFE AG', 'Munich', 'DE', 'DE192847563', '44-591-7823', 'ZSTD', 'NET30');
INSERT INTO LFA1 VALUES ('V10156', 'OSAKA PRECISION INSTRUMENTS CO.', 'Osaka', 'JP', 'JP8120001098765', '69-247-1058', 'ZSTR', 'NET60');
INSERT INTO LFA1 VALUES ('V10167', 'GUANGZHOU RARE EARTH MATERIALS LTD', 'Guangzhou', 'CN', '91440101MA9URXG44N', '63-904-2175', 'ZSTD', 'NET60');
INSERT INTO LFA1 VALUES ('V10190', 'SCHWARZWALD PRECISION TOOLS GMBH', 'Freiburg', 'DE', 'DE314725890', '37-462-8105', 'ZSTD', 'NET30');
INSERT INTO LFA1 VALUES ('V10201', 'MONTERREY PACKAGING S.A. DE C.V.', 'Monterrey', 'MX', 'MPS040512QR7', '82-461-3097', 'ZSTD', 'NET30');
INSERT INTO LFA1 VALUES ('V10223', 'LONE STAR INDUSTRIAL SUPPLY CO.', 'Houston', 'US', '76-1948302', '28-617-4930', 'ZSTD', 'NET30');
INSERT INTO LFA1 VALUES ('V10245', 'PUEBLA CORRUGATED PRODUCTS SA', 'Puebla', 'MX', 'PCP090318HV5', NULL, 'ZPRB', 'NET30');
INSERT INTO LFA1 VALUES ('V10278', 'JIANGSU COPPER ALLOYS CO. LTD', 'Nanjing', 'CN', '91320100MA1MPKG28R', '56-813-4027', 'ZSTD', 'NET45');
INSERT INTO LFA1 VALUES ('V10312', 'ACME LOGISTICS INC', 'Chicago', 'US', '36-4829107', '09-284-5716', 'ZSTD', 'NET30');
INSERT INTO LFA1 VALUES ('V10334', 'NAGOYA STEEL WORKS LTD', 'Nagoya', 'JP', 'JP3180001054321', '48-729-3061', 'ZSTD', 'NET60');

-- =====================================================
-- LFA2: Carriers (Forwarding Agents)
-- =====================================================
CREATE OR REPLACE TABLE LFA2 (
    TDLNR VARCHAR(10) NOT NULL PRIMARY KEY, -- Forwarding agent number
    NAME1 VARCHAR(100),                     -- Carrier name
    VSART VARCHAR(5),                       -- Transport type (01=Ocean, 02=FTL, 03=Air, 04=Intermodal, 05=LTL)
    LZEIT NUMBER(38,0),                     -- Transit time (days)
    OTRAT NUMBER(4,2)                       -- On-time rate (carrier self-reported)
);

INSERT INTO LFA2 VALUES ('CAR-001', 'TransGlobal Freight Inc.', '01', 28, 0.87);
INSERT INTO LFA2 VALUES ('CAR-002', 'EuroHaul Logistics GmbH', '02', 4, 0.94);
INSERT INTO LFA2 VALUES ('CAR-003', 'SkyBridge Air Cargo', '03', 3, 0.96);
INSERT INTO LFA2 VALUES ('CAR-004', 'Pacific Intermodal Corp.', '04', 18, 0.91);
INSERT INTO LFA2 VALUES ('CAR-005', 'MexLine Transportes S.A.', '05', 6, 0.83);
INSERT INTO LFA2 VALUES ('CAR-006', 'Shenzhen Coastal Shipping Ltd.', '01', 22, 0.89);

-- =====================================================
-- MARA: Material Master
-- =====================================================
CREATE OR REPLACE TABLE MARA (
    MATNR VARCHAR(10) NOT NULL PRIMARY KEY, -- Material number
    MAKTX VARCHAR(100),                     -- Material description
    MATKL VARCHAR(5),                       -- Material group code
    STPRS NUMBER(10,2)                      -- Standard price
);

INSERT INTO MARA VALUES ('ASSY-001', 'Sensor Module Assembly', '048', 45.00);
INSERT INTO MARA VALUES ('ASSY-002', 'Power Distribution Board', '048', 32.00);
INSERT INTO MARA VALUES ('ASSY-003', 'Ruggedized Enclosure', '048', 380.00);
INSERT INTO MARA VALUES ('ASSY-004', 'Integrated System Module', '048', 520.00);
INSERT INTO MARA VALUES ('MAT-001', 'Multilayer Ceramic Capacitor 100nF', '043', 0.12);
INSERT INTO MARA VALUES ('MAT-002', 'Epoxy Resin ER-4500', '044', 18.50);
INSERT INTO MARA VALUES ('MAT-003', 'Aluminum Sheet 6061-T6 2mm', '045', 42.00);
INSERT INTO MARA VALUES ('MAT-004', 'MEMS Accelerometer IC', '043', 3.75);
INSERT INTO MARA VALUES ('MAT-005', 'Corrugated Box 400x300x200mm', '046', 1.85);
INSERT INTO MARA VALUES ('MAT-006', 'Isopropyl Alcohol 99.7%', '044', 5.20);
INSERT INTO MARA VALUES ('MAT-007', 'Copper Alloy Strip C17200', '045', 28.90);
INSERT INTO MARA VALUES ('MAT-008', 'ARM Cortex-M4 Microcontroller', '043', 6.40);
INSERT INTO MARA VALUES ('MAT-009', 'Anti-Static Foam Insert', '046', 0.95);
INSERT INTO MARA VALUES ('MAT-010', 'Stainless Steel Rod 304L 10mm', '045', 12.30);
INSERT INTO MARA VALUES ('MAT-011', 'Neodymium Rare Earth Magnet N52', '047', 2.10);
INSERT INTO MARA VALUES ('MAT-012', 'Silicone Thermal Paste TG-7', '044', 85.00);
INSERT INTO MARA VALUES ('MAT-013', 'Power MOSFET IRF540N', '043', 0.85);
INSERT INTO MARA VALUES ('MAT-014', 'Polyethylene Stretch Wrap 500mm', '046', 14.50);
INSERT INTO MARA VALUES ('MAT-015', 'Titanium Alloy Ti-6Al-4V Plate', '045', 120.00);
INSERT INTO MARA VALUES ('MAT-016', 'Fiber Optic Transceiver SFP+ 10G', '043', 22.00);
INSERT INTO MARA VALUES ('MAT-017', 'Hydrochloric Acid 37% ACS Grade', '044', 8.75);
INSERT INTO MARA VALUES ('MAT-018', 'Precision Ball Bearing 6205-2RS', '047', 4.50);
INSERT INTO MARA VALUES ('MAT-019', 'Carbon Fiber Sheet 3K Twill 2mm', '047', 65.00);
INSERT INTO MARA VALUES ('MAT-020', 'ESD Protective Bag 200x300mm', '046', 0.35);

-- =====================================================
-- T001W: Plants
-- =====================================================
CREATE OR REPLACE TABLE T001W (
    WERKS VARCHAR(10) NOT NULL PRIMARY KEY, -- Plant code
    NAME1 VARCHAR(100),                     -- Plant name
    REGIO VARCHAR(20)                       -- Region
);

INSERT INTO T001W VALUES ('PLT-001', 'Austin Manufacturing Center', 'AMERICAS');
INSERT INTO T001W VALUES ('PLT-002', 'Stuttgart Assembly Plant', 'EMEA');
INSERT INTO T001W VALUES ('PLT-003', 'Shanghai Production Facility', 'APAC');
INSERT INTO T001W VALUES ('PLT-004', 'Monterrey Operations Plant', 'AMERICAS');
INSERT INTO T001W VALUES ('PLT-005', 'Nagoya Precision Works', 'APAC');

-- =====================================================
-- T320: Storage Locations (Warehouses)
-- =====================================================
CREATE OR REPLACE TABLE T320 (
    LGORT VARCHAR(10) NOT NULL PRIMARY KEY, -- Storage location
    LGOBE VARCHAR(100),                     -- Storage location description
    WERKS VARCHAR(10),                      -- Plant
    LKAPA NUMBER(5,1)                       -- Capacity utilization %
);

INSERT INTO T320 VALUES ('WH-001', 'Austin Raw Materials Hub', 'PLT-001', 72.5);
INSERT INTO T320 VALUES ('WH-002', 'Austin Finished Goods Depot', 'PLT-001', 61.0);
INSERT INTO T320 VALUES ('WH-003', 'Stuttgart Inbound Logistics Center', 'PLT-002', 88.3);
INSERT INTO T320 VALUES ('WH-004', 'Shanghai Bonded Warehouse', 'PLT-003', 55.2);
INSERT INTO T320 VALUES ('WH-005', 'Shanghai Distribution Center', 'PLT-003', 79.8);
INSERT INTO T320 VALUES ('WH-006', 'Monterrey Cross-Dock Facility', 'PLT-004', 42.1);
INSERT INTO T320 VALUES ('WH-007', 'Nagoya JIT Storage', 'PLT-005', 91.7);
INSERT INTO T320 VALUES ('WH-008', 'Houston Regional Distribution Hub', 'PLT-001', 67.4);

-- =============================================================================
-- TRANSACTIONS
-- =============================================================================

-- =====================================================
-- EKPO: Purchase Order Items
-- =====================================================
CREATE OR REPLACE TABLE EKPO (
    EBELN VARCHAR(20) NOT NULL,             -- PO number
    EBELP VARCHAR(5) NOT NULL,              -- PO item number
    LIFNR VARCHAR(10),                      -- Vendor number
    MATNR VARCHAR(10),                      -- Material number
    WERKS VARCHAR(10),                      -- Plant
    BEDAT DATE,                             -- Order date
    MENGE NUMBER(38,0),                     -- Quantity
    NETWR NUMBER(12,2),                     -- Net value (USD)
    STATU VARCHAR(5),                       -- Status (O=Open, C=Closed, R=Received)
    PRIMARY KEY (EBELN, EBELP)
);

INSERT INTO EKPO VALUES ('PO-2024-001', '10', 'V10045', 'MAT-001', 'PLT-003', '2024-09-15', 100000, 11000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-002', '10', 'V10078', 'MAT-002', 'PLT-002', '2024-09-20', 5000, 89000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-003', '10', 'V10089', 'MAT-003', 'PLT-001', '2024-10-01', 1200, 48600.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-004', '10', 'V10098', 'MAT-004', 'PLT-005', '2024-10-10', 20000, 72000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-005', '10', 'V10102', 'MAT-005', 'PLT-004', '2024-10-15', 15000, 26250.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-006', '10', 'V10134', 'MAT-008', 'PLT-001', '2024-11-01', 10000, 62000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-007', '10', 'V10156', 'MAT-002', 'PLT-002', '2024-11-10', 3000, 57300.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-008', '10', 'V10167', 'MAT-011', 'PLT-003', '2024-11-15', 50000, 97500.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-009', '10', 'V10278', 'MAT-007', 'PLT-003', '2024-12-01', 2000, 55000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-010', '10', 'V10334', 'MAT-010', 'PLT-005', '2024-12-05', 5000, 59000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-011', '10', 'V10102', 'MAT-014', 'PLT-004', '2024-11-20', 800, 11040.00, 'R');
INSERT INTO EKPO VALUES ('PO-2024-012', '10', 'V10201', 'MAT-004', 'PLT-001', '2024-12-10', 8000, 30400.00, 'O');
INSERT INTO EKPO VALUES ('PO-2025-001', '10', 'V10045', 'MAT-013', 'PLT-003', '2025-01-10', 50000, 41000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2025-002', '10', 'V10201', 'MAT-016', 'PLT-005', '2025-01-20', 4000, 84000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2025-003', '10', 'V10190', 'MAT-006', 'PLT-001', '2025-02-01', 10000, 49000.00, 'R');
INSERT INTO EKPO VALUES ('PO-2025-004', '10', 'V10312', 'MAT-018', 'PLT-002', '2025-02-15', 8000, 34400.00, 'R');
INSERT INTO EKPO VALUES ('PO-2025-005', '10', 'V10089', 'MAT-015', 'PLT-001', '2025-03-01', 300, 34500.00, 'R');
INSERT INTO EKPO VALUES ('PO-2025-006', '10', 'V10134', 'MAT-008', 'PLT-001', '2025-03-15', 15000, 93000.00, 'O');
INSERT INTO EKPO VALUES ('PO-2025-007', '10', 'V10078', 'MAT-017', 'PLT-002', '2025-04-01', 8000, 67200.00, 'O');
INSERT INTO EKPO VALUES ('PO-2025-008', '10', 'V10223', 'MAT-005', 'PLT-004', '2025-04-05', 20000, 33000.00, 'O');
INSERT INTO EKPO VALUES ('PO-2025-009', '10', 'V10098', 'MAT-004', 'PLT-005', '2025-04-10', 25000, 90000.00, 'O');
INSERT INTO EKPO VALUES ('PO-2025-010', '10', 'V10167', 'MAT-011', 'PLT-003', '2025-04-12', 40000, 80000.00, 'O');
INSERT INTO EKPO VALUES ('PO-2025-011', '10', 'V10045', 'MAT-001', 'PLT-001', '2025-04-15', 200000, 22000.00, 'O');
INSERT INTO EKPO VALUES ('PO-2025-012', '10', 'V10278', 'MAT-007', 'PLT-003', '2025-04-16', 3000, 84000.00, 'O');
INSERT INTO EKPO VALUES ('PO-2025-013', '10', 'V10245', 'MAT-009', 'PLT-001', '2025-03-01', 25000, 22500.00, 'R');

-- =====================================================
-- LIKP: Shipments
-- =====================================================
CREATE OR REPLACE TABLE LIKP (
    TKNUM VARCHAR(10) NOT NULL PRIMARY KEY, -- Shipment number
    TDLNR VARCHAR(10),                      -- Forwarding agent (carrier)
    LGORT_SRC VARCHAR(10),                  -- Source storage location (origin warehouse)
    WERKS_DST VARCHAR(10),                  -- Destination plant
    MATNR VARCHAR(10),                      -- Material
    MENGE NUMBER(38,0),                     -- Quantity
    LFDAT DATE,                             -- Expected arrival
    WADAT DATE,                             -- Actual arrival
    FRTCO NUMBER(10,2),                     -- Freight cost
    STATU VARCHAR(5)                        -- Status (D=Delivered, T=In Transit, X=Delayed)
);

INSERT INTO LIKP VALUES ('SHP-001', 'CAR-006', 'WH-004', 'PLT-001', 'MAT-001', 100000, '2024-10-10', '2024-10-08', 2800.00, 'D');
INSERT INTO LIKP VALUES ('SHP-002', 'CAR-002', 'WH-003', 'PLT-002', 'MAT-002', 5000, '2024-09-26', '2024-09-25', 1200.00, 'D');
INSERT INTO LIKP VALUES ('SHP-003', 'CAR-003', 'WH-008', NULL, 'MAT-003', 1200, '2024-10-06', '2024-10-06', 3500.00, 'D');
INSERT INTO LIKP VALUES ('SHP-004', 'CAR-004', 'WH-007', 'PLT-005', 'MAT-004', 20000, '2024-11-02', '2024-11-05', 4200.00, 'D');
INSERT INTO LIKP VALUES ('SHP-005', 'CAR-005', 'WH-006', 'PLT-004', 'MAT-005', 15000, '2024-10-23', '2024-10-22', 850.00, 'D');
INSERT INTO LIKP VALUES ('SHP-006', 'CAR-003', 'WH-001', NULL, 'MAT-008', 10000, '2024-11-11', '2024-11-11', 5100.00, 'D');
INSERT INTO LIKP VALUES ('SHP-007', 'CAR-001', 'WH-004', NULL, 'MAT-011', 50000, '2024-12-18', '2024-12-22', 3100.00, 'D');
INSERT INTO LIKP VALUES ('SHP-008', 'CAR-006', 'WH-005', NULL, 'MAT-007', 2000, '2024-12-27', '2024-12-26', 1900.00, 'D');
INSERT INTO LIKP VALUES ('SHP-009', 'CAR-002', 'WH-003', 'PLT-002', 'MAT-018', 8000, '2025-02-22', '2025-02-21', 980.00, 'D');
INSERT INTO LIKP VALUES ('SHP-010', 'CAR-004', 'WH-007', NULL, 'MAT-016', 4000, '2025-02-12', '2025-02-14', 3800.00, 'D');
INSERT INTO LIKP VALUES ('SHP-011', 'CAR-001', 'WH-008', NULL, 'MAT-006', 10000, '2025-03-05', '2025-03-08', 2400.00, 'D');
INSERT INTO LIKP VALUES ('SHP-012', 'CAR-003', 'WH-001', 'PLT-001', 'MAT-015', 300, '2025-03-23', '2025-03-23', 1800.00, 'D');
INSERT INTO LIKP VALUES ('SHP-013', 'CAR-006', 'WH-004', 'PLT-003', 'MAT-013', 50000, '2025-02-06', '2025-02-04', 2200.00, 'D');
INSERT INTO LIKP VALUES ('SHP-014', 'CAR-005', 'WH-006', 'PLT-004', 'MAT-014', 800, '2024-11-28', '2024-11-30', 450.00, 'D');
INSERT INTO LIKP VALUES ('SHP-015', 'CAR-002', 'WH-003', 'PLT-002', 'MAT-002', 3000, '2025-03-29', '2025-03-28', 1100.00, 'D');
INSERT INTO LIKP VALUES ('SHP-016', 'CAR-001', 'WH-005', NULL, 'MAT-011', 40000, '2025-05-12', NULL, 3050.00, 'T');
INSERT INTO LIKP VALUES ('SHP-017', 'CAR-004', 'WH-007', 'PLT-005', 'MAT-004', 25000, '2025-05-03', NULL, 4500.00, 'T');
INSERT INTO LIKP VALUES ('SHP-018', 'CAR-003', 'WH-001', NULL, 'MAT-008', 8000, '2025-04-13', NULL, 4800.00, 'X');
INSERT INTO LIKP VALUES ('SHP-019', 'CAR-006', 'WH-004', NULL, 'MAT-007', 3000, '2025-05-10', NULL, 2600.00, 'T');
INSERT INTO LIKP VALUES ('SHP-020', 'CAR-005', 'WH-006', 'PLT-004', 'MAT-005', 20000, '2025-04-14', NULL, 920.00, 'X');

-- =====================================================
-- LFB1: Vendor Contracts
-- =====================================================
CREATE OR REPLACE TABLE LFB1 (
    LIFNR VARCHAR(10) NOT NULL,             -- Vendor
    VKONT VARCHAR(10) NOT NULL,             -- Contract number
    VTART VARCHAR(5),                       -- Contract type (M=Master, F=Framework, S=Spot)
    DTEND DATE,                             -- Expiration date
    JWERT NUMBER(12,2),                     -- Annual value
    PRIMARY KEY (LIFNR, VKONT)
);

INSERT INTO LFB1 VALUES ('V10045', 'CTR-001', 'M', '2026-12-31', 4500000.00);
INSERT INTO LFB1 VALUES ('V10078', 'CTR-002', 'M', '2026-06-30', 3200000.00);
INSERT INTO LFB1 VALUES ('V10089', 'CTR-003', 'F', '2026-03-31', 2800000.00);
INSERT INTO LFB1 VALUES ('V10098', 'CTR-004', 'M', '2027-12-31', 5200000.00);
INSERT INTO LFB1 VALUES ('V10102', 'CTR-005', 'F', '2025-05-31', 450000.00);
INSERT INTO LFB1 VALUES ('V10134', 'CTR-006', 'M', '2027-02-28', 7000000.00);
INSERT INTO LFB1 VALUES ('V10156', 'CTR-007', 'F', '2025-12-31', 1200000.00);
INSERT INTO LFB1 VALUES ('V10167', 'CTR-008', 'S', '2025-09-30', 980000.00);
INSERT INTO LFB1 VALUES ('V10190', 'CTR-015', 'F', '2025-07-31', 600000.00);
INSERT INTO LFB1 VALUES ('V10201', 'CTR-009', 'M', '2026-03-31', 3800000.00);
INSERT INTO LFB1 VALUES ('V10223', 'CTR-014', 'S', '2025-07-15', 250000.00);
INSERT INTO LFB1 VALUES ('V10245', 'CTR-010', 'F', '2025-12-31', 2000000.00);
INSERT INTO LFB1 VALUES ('V10278', 'CTR-011', 'M', '2026-05-31', 1500000.00);
INSERT INTO LFB1 VALUES ('V10312', 'CTR-012', 'F', '2025-12-31', 800000.00);
INSERT INTO LFB1 VALUES ('V10334', 'CTR-013', 'M', '2026-09-30', 3500000.00);

-- =====================================================
-- QALS: Inspection Lots
-- =====================================================
CREATE OR REPLACE TABLE QALS (
    PRUEFLOS VARCHAR(10) NOT NULL PRIMARY KEY, -- Inspection lot
    MATNR VARCHAR(10),                         -- Material
    QAESSION NUMBER(6,3),                      -- Defect rate
    VCODE VARCHAR(5)                           -- Disposition (A=Accepted, R=Rejected, C=Conditional)
);

INSERT INTO QALS VALUES ('INS-001', 'MAT-001', 0.006, 'A');
INSERT INTO QALS VALUES ('INS-002', 'MAT-002', 0.060, 'C');
INSERT INTO QALS VALUES ('INS-003', 'MAT-003', 0.001, 'A');
INSERT INTO QALS VALUES ('INS-004', 'MAT-004', 0.150, 'A');
INSERT INTO QALS VALUES ('INS-005', 'MAT-005', 0.011, 'A');
INSERT INTO QALS VALUES ('INS-006', 'MAT-006', 0.005, 'A');
INSERT INTO QALS VALUES ('INS-007', 'MAT-007', 0.050, 'C');
INSERT INTO QALS VALUES ('INS-008', 'MAT-008', 0.000, 'A');
INSERT INTO QALS VALUES ('INS-009', 'MAT-001', 0.010, 'A');
INSERT INTO QALS VALUES ('INS-010', 'MAT-003', 0.002, 'A');

-- =============================================================================
-- STRUCTURE
-- =============================================================================

-- =====================================================
-- STPO: BOM Items
-- =====================================================
CREATE OR REPLACE TABLE STPO (
    STLNR VARCHAR(10) NOT NULL,             -- BOM number
    IDNRK VARCHAR(10) NOT NULL,             -- Component material
    MENGE NUMBER(10,3),                     -- Quantity per unit
    STUFE NUMBER(38,0),                     -- BOM level
    PRIMARY KEY (STLNR, IDNRK)
);

INSERT INTO STPO VALUES ('ASSY-001', 'MAT-001', 10.000, 1);
INSERT INTO STPO VALUES ('ASSY-001', 'MAT-004', 2.000, 1);
INSERT INTO STPO VALUES ('ASSY-001', 'MAT-008', 1.000, 1);
INSERT INTO STPO VALUES ('ASSY-001', 'MAT-012', 0.050, 1);
INSERT INTO STPO VALUES ('ASSY-002', 'MAT-001', 20.000, 1);
INSERT INTO STPO VALUES ('ASSY-002', 'MAT-007', 0.500, 1);
INSERT INTO STPO VALUES ('ASSY-002', 'MAT-013', 4.000, 1);
INSERT INTO STPO VALUES ('ASSY-003', 'ASSY-001', 1.000, 1);
INSERT INTO STPO VALUES ('ASSY-003', 'ASSY-002', 1.000, 1);
INSERT INTO STPO VALUES ('ASSY-003', 'MAT-003', 2.000, 1);
INSERT INTO STPO VALUES ('ASSY-003', 'MAT-015', 0.300, 1);
INSERT INTO STPO VALUES ('ASSY-003', 'MAT-019', 1.000, 1);
INSERT INTO STPO VALUES ('ASSY-004', 'ASSY-003', 1.000, 1);
INSERT INTO STPO VALUES ('ASSY-004', 'MAT-016', 2.000, 1);
INSERT INTO STPO VALUES ('ASSY-004', 'MAT-018', 4.000, 1);

-- =====================================================
-- QUAL_MATRIX: Alternate Supplier Qualifications
-- (Quality engineering data)
-- =====================================================
CREATE OR REPLACE TABLE QUAL_MATRIX (
    MATNR VARCHAR(10) NOT NULL,             -- Material number
    LIFNR VARCHAR(10) NOT NULL,             -- Vendor number
    QUAL_STATUS VARCHAR(10),                -- APPROVED, PENDING, EXPIRED, REJECTED
    QUAL_DATE DATE,                         -- Qualification date
    PRIMARY KEY (MATNR, LIFNR)
);

INSERT INTO QUAL_MATRIX VALUES ('MAT-001', 'V10045', 'APPROVED', '2023-06-15');
INSERT INTO QUAL_MATRIX VALUES ('MAT-001', 'V10048', 'APPROVED', '2024-01-20');
INSERT INTO QUAL_MATRIX VALUES ('MAT-001', 'V10052', 'PENDING', '2025-03-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-002', 'V10054', 'APPROVED', '2023-07-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-002', 'V10056', 'APPROVED', '2024-03-10');
INSERT INTO QUAL_MATRIX VALUES ('MAT-003', 'V10053', 'APPROVED', '2023-04-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-003', 'V10060', 'APPROVED', '2024-11-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-004', 'V10055', 'APPROVED', '2023-09-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-004', 'V10057', 'APPROVED', '2024-07-15');
INSERT INTO QUAL_MATRIX VALUES ('MAT-005', 'V10057', 'APPROVED', '2024-08-20');
INSERT INTO QUAL_MATRIX VALUES ('MAT-005', 'V10059', 'APPROVED', '2023-11-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-006', 'V10049', 'APPROVED', '2023-06-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-007', 'V10051', 'APPROVED', '2023-05-20');
INSERT INTO QUAL_MATRIX VALUES ('MAT-008', 'V10045', 'EXPIRED', '2022-12-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-008', 'V10055', 'APPROVED', '2024-05-10');
INSERT INTO QUAL_MATRIX VALUES ('MAT-009', 'V10057', 'APPROVED', '2024-02-15');
INSERT INTO QUAL_MATRIX VALUES ('MAT-010', 'V10055', 'APPROVED', '2023-12-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-011', 'V10050', 'APPROVED', '2023-08-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-012', 'V10049', 'APPROVED', '2023-05-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-012', 'V10054', 'APPROVED', '2024-04-15');
INSERT INTO QUAL_MATRIX VALUES ('MAT-013', 'V10045', 'APPROVED', '2023-06-15');
INSERT INTO QUAL_MATRIX VALUES ('MAT-014', 'V10057', 'APPROVED', '2023-08-20');
INSERT INTO QUAL_MATRIX VALUES ('MAT-015', 'V10053', 'APPROVED', '2023-10-15');
INSERT INTO QUAL_MATRIX VALUES ('MAT-015', 'V10058', 'PENDING', '2025-06-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-016', 'V10057', 'APPROVED', '2024-01-10');
INSERT INTO QUAL_MATRIX VALUES ('MAT-017', 'V10049', 'APPROVED', '2023-09-01');
INSERT INTO QUAL_MATRIX VALUES ('MAT-018', 'V10055', 'APPROVED', '2023-07-15');
INSERT INTO QUAL_MATRIX VALUES ('MAT-019', 'V10049', 'APPROVED', '2023-06-01');

-- =============================================================================
-- FINANCE
-- =============================================================================

-- =====================================================
-- BSEG: Accounting Document Segment
-- =====================================================
CREATE OR REPLACE TABLE BSEG (
    BELNR VARCHAR(10) NOT NULL,             -- Accounting document number
    BUZEI VARCHAR(3) NOT NULL,              -- Line item number
    EBELN VARCHAR(20),                      -- Purchase order number
    LIFNR VARCHAR(10),                      -- Vendor number
    HKONT VARCHAR(15),                      -- G/L account number
    DMBTR NUMBER(12,2),                     -- Amount in local currency
    BUDAT DATE,                             -- Posting date
    BSCHL VARCHAR(3),                       -- Posting key (31=vendor invoice, 34=debit memo)
    GJAHR NUMBER(4,0),                      -- Fiscal year
    MONAT NUMBER(2,0),                      -- Fiscal period
    PRIMARY KEY (BELNR, BUZEI)
);

INSERT INTO BSEG VALUES ('5100000001', '001', 'PO-2024-001', 'V10045', '0040100000', 11000.00, '2024-10-15', '31', 2024, 10);
INSERT INTO BSEG VALUES ('5100000002', '001', 'PO-2024-002', 'V10078', '0040100000', 89000.00, '2024-10-20', '31', 2024, 10);
INSERT INTO BSEG VALUES ('5100000003', '001', 'PO-2024-003', 'V10089', '0040100000', 48600.00, '2024-11-01', '31', 2024, 11);
INSERT INTO BSEG VALUES ('5100000004', '001', 'PO-2024-004', 'V10098', '0040100000', 72000.00, '2024-11-10', '31', 2024, 11);
INSERT INTO BSEG VALUES ('5100000005', '001', 'PO-2024-005', 'V10102', '0040100000', 26250.00, '2024-11-15', '31', 2024, 11);
INSERT INTO BSEG VALUES ('5100000006', '001', 'PO-2024-006', 'V10134', '0040100000', 62000.00, '2024-12-01', '31', 2024, 12);
INSERT INTO BSEG VALUES ('5100000007', '001', 'PO-2024-007', 'V10156', '0040100000', 57300.00, '2024-12-10', '31', 2024, 12);
INSERT INTO BSEG VALUES ('5100000008', '001', 'PO-2024-008', 'V10167', '0040100000', 97500.00, '2024-12-15', '31', 2024, 12);
INSERT INTO BSEG VALUES ('5100000009', '001', 'PO-2024-009', 'V10278', '0040100000', 55000.00, '2025-01-01', '31', 2025, 1);
INSERT INTO BSEG VALUES ('5100000010', '001', 'PO-2024-010', 'V10334', '0040100000', 59000.00, '2025-01-05', '31', 2025, 1);
INSERT INTO BSEG VALUES ('5100000011', '001', 'PO-2024-011', 'V10102', '0040100000', 11040.00, '2024-12-20', '31', 2024, 12);
INSERT INTO BSEG VALUES ('5100000012', '001', 'PO-2024-012', 'V10201', '0040100000', 30400.00, '2025-01-10', '31', 2025, 1);
INSERT INTO BSEG VALUES ('5100000013', '001', 'PO-2025-001', 'V10045', '0040100000', 41000.00, '2025-02-10', '31', 2025, 2);
INSERT INTO BSEG VALUES ('5100000014', '001', 'PO-2025-002', 'V10201', '0040100000', 84000.00, '2025-02-20', '31', 2025, 2);
INSERT INTO BSEG VALUES ('5100000015', '001', 'PO-2025-003', 'V10190', '0040100000', 49000.00, '2025-03-01', '31', 2025, 3);
INSERT INTO BSEG VALUES ('5100000016', '001', 'PO-2025-004', 'V10312', '0040100000', 34400.00, '2025-03-15', '31', 2025, 3);
INSERT INTO BSEG VALUES ('5100000017', '001', 'PO-2025-005', 'V10089', '0040100000', 34500.00, '2025-04-01', '31', 2025, 4);
INSERT INTO BSEG VALUES ('5100000018', '001', 'PO-2025-006', 'V10134', '0040100000', 93000.00, '2025-04-15', '31', 2025, 4);
INSERT INTO BSEG VALUES ('5100000019', '001', 'PO-2025-007', 'V10078', '0040100000', 67200.00, '2025-05-01', '31', 2025, 5);
INSERT INTO BSEG VALUES ('5100000020', '001', 'PO-2025-008', 'V10223', '0040100000', 33000.00, '2025-05-05', '31', 2025, 5);
INSERT INTO BSEG VALUES ('5100000021', '001', 'PO-2025-009', 'V10098', '0040100000', 90000.00, '2025-05-10', '31', 2025, 5);
INSERT INTO BSEG VALUES ('5100000022', '001', 'PO-2025-010', 'V10167', '0040100000', 80000.00, '2025-05-12', '31', 2025, 5);
INSERT INTO BSEG VALUES ('5100000023', '001', 'PO-2025-011', 'V10045', '0040100000', 22000.00, '2025-05-15', '31', 2025, 5);
INSERT INTO BSEG VALUES ('5100000024', '001', 'PO-2025-012', 'V10278', '0040100000', 84000.00, '2025-05-16', '31', 2025, 5);
INSERT INTO BSEG VALUES ('5100000025', '001', 'PO-2025-013', 'V10245', '0040100000', 22500.00, '2025-04-01', '31', 2025, 4);
INSERT INTO BSEG VALUES ('5100000030', '001', 'PO-2024-003', 'V10089', '0040100000', 12150.00, '2024-12-01', '34', 2024, 12);
INSERT INTO BSEG VALUES ('5100000031', '001', 'PO-2024-008', 'V10167', '0040100000', 19500.00, '2025-01-15', '34', 2025, 1);
INSERT INTO BSEG VALUES ('5100000032', '001', 'PO-2025-003', 'V10190', '0040100000', 9800.00, '2025-04-01', '34', 2025, 4);
INSERT INTO BSEG VALUES ('5100000033', '001', 'PO-2025-007', 'V10078', '0040100000', 6720.00, '2025-06-01', '34', 2025, 6);
INSERT INTO BSEG VALUES ('5100000034', '001', 'PO-2024-006', 'V10134', '0040100000', 15500.00, '2025-02-01', '34', 2025, 2);
INSERT INTO BSEG VALUES ('5100000040', '001', 'PO-2024-001', 'V10045', '0040200000', 2200.00, '2024-10-20', '31', 2024, 10);
INSERT INTO BSEG VALUES ('5100000041', '001', 'PO-2024-004', 'V10098', '0040200000', 8500.00, '2024-11-15', '31', 2024, 11);
INSERT INTO BSEG VALUES ('5100000042', '001', 'PO-2025-002', 'V10201', '0040200000', 12600.00, '2025-03-01', '31', 2025, 3);
INSERT INTO BSEG VALUES ('5100000043', '001', 'PO-2025-009', 'V10098', '0040200000', 11000.00, '2025-05-15', '31', 2025, 5);
INSERT INTO BSEG VALUES ('5100000044', '001', 'PO-2025-006', 'V10134', '0040200000', 5500.00, '2025-04-20', '31', 2025, 4);
INSERT INTO BSEG VALUES ('5100000050', '001', 'PO-2024-001', 'V10045', '0021100000', 13200.00, '2024-10-15', '31', 2024, 10);
INSERT INTO BSEG VALUES ('5100000051', '001', 'PO-2025-009', 'V10098', '0021100000', 101000.00, '2025-05-10', '31', 2025, 5);
INSERT INTO BSEG VALUES ('5100000052', '001', 'PO-2025-006', 'V10134', '0021100000', 98500.00, '2025-04-15', '31', 2025, 4);

-- =====================================================
-- COEP: CO Line Items (Cost Element Postings)
-- =====================================================
CREATE OR REPLACE TABLE COEP (
    OBJNR VARCHAR(20),                      -- Cost center / object number
    KSTAR VARCHAR(15),                      -- Cost element
    WRTBTR NUMBER(12,2),                    -- Amount in controlling area currency
    GJAHR NUMBER(4,0),                      -- Fiscal year
    PERIO NUMBER(2,0),                      -- Posting period
    MATNR VARCHAR(10)                       -- Material number
);

INSERT INTO COEP VALUES ('KS-LOG', '0047000000', 39800.00, 2025, 1, NULL);
INSERT INTO COEP VALUES ('KS-LOG', '0047000000', 42100.00, 2025, 2, NULL);
INSERT INTO COEP VALUES ('KS-MFG-AP', '0040100000', 177500.00, 2025, 1, 'MAT-011');
INSERT INTO COEP VALUES ('KS-MFG-AP', '0040100000', 139000.00, 2025, 2, 'MAT-007');
INSERT INTO COEP VALUES ('KS-MFG-AP', '0040100000', 74000.00, 2025, 3, 'MAT-001');
INSERT INTO COEP VALUES ('KS-MFG-AP', '0047000000', 31200.00, 2025, 1, NULL);
INSERT INTO COEP VALUES ('KS-MFG-AP', '0048000000', 14800.00, 2025, 2, NULL);
INSERT INTO COEP VALUES ('KS-MFG-EU', '0040100000', 213500.00, 2025, 1, 'MAT-002');
INSERT INTO COEP VALUES ('KS-MFG-EU', '0040100000', 67200.00, 2025, 2, 'MAT-017');
INSERT INTO COEP VALUES ('KS-MFG-EU', '0040100000', 34400.00, 2025, 3, 'MAT-018');
INSERT INTO COEP VALUES ('KS-MFG-EU', '0047000000', 22300.00, 2025, 1, NULL);
INSERT INTO COEP VALUES ('KS-MFG-EU', '0048000000', 11500.00, 2025, 2, NULL);
INSERT INTO COEP VALUES ('KS-MFG-US', '0040100000', 172550.00, 2025, 1, 'MAT-003');
INSERT INTO COEP VALUES ('KS-MFG-US', '0040100000', 127500.00, 2025, 2, 'MAT-004');
INSERT INTO COEP VALUES ('KS-MFG-US', '0040100000', 93000.00, 2025, 3, 'MAT-008');
INSERT INTO COEP VALUES ('KS-MFG-US', '0047000000', 18500.00, 2025, 1, NULL);
INSERT INTO COEP VALUES ('KS-MFG-US', '0048000000', 8200.00, 2025, 1, NULL);
INSERT INTO COEP VALUES ('KS-QA', '0048000000', 22000.00, 2025, 1, NULL);
INSERT INTO COEP VALUES ('KS-QA', '0048000000', 18500.00, 2025, 2, NULL);

-- =============================================================================
-- SALES
-- =============================================================================

-- =====================================================
-- VBAP: Sales Order Items
-- =====================================================
CREATE OR REPLACE TABLE VBAP (
    VBELN VARCHAR(10) NOT NULL,             -- Sales document number
    POSNR VARCHAR(5) NOT NULL,              -- Sales document item
    MATNR VARCHAR(10),                      -- Material number
    KWMENG NUMBER(10,0),                    -- Order quantity
    NETWR NUMBER(12,2),                     -- Net value
    KUNNR VARCHAR(10),                      -- Customer number
    ERDAT DATE,                             -- Created on date
    VKORG VARCHAR(5),                       -- Sales organization
    PRIMARY KEY (VBELN, POSNR)
);

INSERT INTO VBAP VALUES ('SO-001', '010', 'ASSY-004', 50, 60000.00, 'C-1001', '2025-01-15', '1000');
INSERT INTO VBAP VALUES ('SO-001', '020', 'ASSY-003', 100, 85000.00, 'C-1001', '2025-01-15', '1000');
INSERT INTO VBAP VALUES ('SO-002', '010', 'ASSY-004', 80, 96000.00, 'C-1002', '2025-02-10', '2000');
INSERT INTO VBAP VALUES ('SO-002', '020', 'ASSY-003', 60, 51000.00, 'C-1002', '2025-02-10', '2000');
INSERT INTO VBAP VALUES ('SO-003', '010', 'ASSY-004', 30, 36000.00, 'C-1003', '2025-03-01', '3000');
INSERT INTO VBAP VALUES ('SO-004', '010', 'ASSY-004', 120, 144000.00, 'C-1001', '2025-04-01', '1000');
INSERT INTO VBAP VALUES ('SO-005', '010', 'ASSY-004', 45, 54000.00, 'C-1004', '2025-04-15', '2000');
INSERT INTO VBAP VALUES ('SO-006', '010', 'ASSY-003', 75, 63750.00, 'C-1005', '2025-03-20', '1000');
INSERT INTO VBAP VALUES ('SO-007', '010', 'ASSY-003', 40, 34000.00, 'C-1003', '2025-05-01', '3000');
INSERT INTO VBAP VALUES ('SO-008', '010', 'ASSY-001', 200, 24000.00, 'C-1001', '2025-02-01', '1000');
INSERT INTO VBAP VALUES ('SO-009', '010', 'ASSY-001', 500, 60000.00, 'C-1004', '2025-04-10', '2000');
INSERT INTO VBAP VALUES ('SO-010', '010', 'ASSY-002', 300, 25500.00, 'C-1002', '2025-03-05', '2000');
INSERT INTO VBAP VALUES ('SO-011', '010', 'ASSY-002', 150, 12750.00, 'C-1005', '2025-05-10', '1000');

-- =====================================================
-- KONV: Pricing Conditions
-- =====================================================
CREATE OR REPLACE TABLE KONV (
    KNUMV VARCHAR(10) NOT NULL,             -- Condition document number
    KPOSN VARCHAR(5) NOT NULL,              -- Item number
    KSCHL VARCHAR(5) NOT NULL,              -- Condition type (PR00=Price, K007=Customer discount, KF00=Freight surcharge)
    KBETR NUMBER(8,2),                      -- Condition rate / percentage
    KWERT NUMBER(12,2),                     -- Condition value
    MATNR VARCHAR(10),                      -- Material number
    KUNNR VARCHAR(10),                      -- Customer number
    PRIMARY KEY (KNUMV, KPOSN, KSCHL)
);

INSERT INTO KONV VALUES ('KN-001', '010', 'K007', 5.00, -3000.00, 'ASSY-004', 'C-1001');
INSERT INTO KONV VALUES ('KN-001', '010', 'PR00', 1200.00, 60000.00, 'ASSY-004', 'C-1001');
INSERT INTO KONV VALUES ('KN-001', '020', 'K007', 5.00, -4250.00, 'ASSY-003', 'C-1001');
INSERT INTO KONV VALUES ('KN-001', '020', 'PR00', 850.00, 85000.00, 'ASSY-003', 'C-1001');
INSERT INTO KONV VALUES ('KN-002', '010', 'K007', 8.00, -7680.00, 'ASSY-004', 'C-1002');
INSERT INTO KONV VALUES ('KN-002', '010', 'PR00', 1200.00, 96000.00, 'ASSY-004', 'C-1002');
INSERT INTO KONV VALUES ('KN-002', '020', 'PR00', 850.00, 51000.00, 'ASSY-003', 'C-1002');
INSERT INTO KONV VALUES ('KN-003', '010', 'KF00', 2.00, 720.00, 'ASSY-004', 'C-1003');
INSERT INTO KONV VALUES ('KN-003', '010', 'PR00', 1200.00, 36000.00, 'ASSY-004', 'C-1003');
INSERT INTO KONV VALUES ('KN-004', '010', 'K007', 5.00, -7200.00, 'ASSY-004', 'C-1001');
INSERT INTO KONV VALUES ('KN-004', '010', 'PR00', 1200.00, 144000.00, 'ASSY-004', 'C-1001');
INSERT INTO KONV VALUES ('KN-005', '010', 'K007', 3.00, -1620.00, 'ASSY-004', 'C-1004');
INSERT INTO KONV VALUES ('KN-005', '010', 'PR00', 1200.00, 54000.00, 'ASSY-004', 'C-1004');
INSERT INTO KONV VALUES ('KN-006', '010', 'K007', 4.00, -2550.00, 'ASSY-003', 'C-1005');
INSERT INTO KONV VALUES ('KN-006', '010', 'PR00', 850.00, 63750.00, 'ASSY-003', 'C-1005');
INSERT INTO KONV VALUES ('KN-007', '010', 'KF00', 3.00, 1020.00, 'ASSY-003', 'C-1003');
INSERT INTO KONV VALUES ('KN-007', '010', 'PR00', 850.00, 34000.00, 'ASSY-003', 'C-1003');
INSERT INTO KONV VALUES ('KN-008', '010', 'KF00', 2.00, 480.00, 'ASSY-001', 'C-1001');
INSERT INTO KONV VALUES ('KN-008', '010', 'PR00', 120.00, 24000.00, 'ASSY-001', 'C-1001');
INSERT INTO KONV VALUES ('KN-009', '010', 'K007', 10.00, -6000.00, 'ASSY-001', 'C-1004');
INSERT INTO KONV VALUES ('KN-009', '010', 'PR00', 120.00, 60000.00, 'ASSY-001', 'C-1004');
INSERT INTO KONV VALUES ('KN-010', '010', 'K007', 7.00, -1785.00, 'ASSY-002', 'C-1002');
INSERT INTO KONV VALUES ('KN-010', '010', 'PR00', 85.00, 25500.00, 'ASSY-002', 'C-1002');
INSERT INTO KONV VALUES ('KN-011', '010', 'KF00', 3.00, 382.50, 'ASSY-002', 'C-1005');
INSERT INTO KONV VALUES ('KN-011', '010', 'PR00', 85.00, 12750.00, 'ASSY-002', 'C-1005');

-- =====================================================
-- Verify row counts
-- =====================================================
SELECT 'LFA1' AS TBL, COUNT(*) AS ROW_COUNT FROM LFA1
UNION ALL SELECT 'LFA2', COUNT(*) FROM LFA2
UNION ALL SELECT 'MARA', COUNT(*) FROM MARA
UNION ALL SELECT 'T001W', COUNT(*) FROM T001W
UNION ALL SELECT 'T320', COUNT(*) FROM T320
UNION ALL SELECT 'EKPO', COUNT(*) FROM EKPO
UNION ALL SELECT 'LIKP', COUNT(*) FROM LIKP
UNION ALL SELECT 'LFB1', COUNT(*) FROM LFB1
UNION ALL SELECT 'QALS', COUNT(*) FROM QALS
UNION ALL SELECT 'STPO', COUNT(*) FROM STPO
UNION ALL SELECT 'QUAL_MATRIX', COUNT(*) FROM QUAL_MATRIX
UNION ALL SELECT 'BSEG', COUNT(*) FROM BSEG
UNION ALL SELECT 'COEP', COUNT(*) FROM COEP
UNION ALL SELECT 'VBAP', COUNT(*) FROM VBAP
UNION ALL SELECT 'KONV', COUNT(*) FROM KONV
ORDER BY TBL;
SENSE_FILE_SQL_02_RAW_DATA_SQL

cat > 'sql/03_sap_schema.sql' <<'SENSE_FILE_SQL_03_SAP_SCHEMA_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- =====================================================================
-- Business Ontology demo, 03: SAP schema, cloned data, reference (code) tables
-- Built objects live in SAP; the source tables stay untouched in RAW.
-- =====================================================================
USE DATABASE SENSE_ONTOLOGY_QS;

CREATE SCHEMA IF NOT EXISTS SENSE_ONTOLOGY_QS.SAP
  COMMENT = 'Business Ontology demo: domain SVs (bare/enriched), governed BON, fair 3-agent benchmark';
USE SCHEMA SENSE_ONTOLOGY_QS.SAP;

-- Zero-copy clone of the SAP source tables from RAW.
-- PREREQUISITE: run 01_setup.sql and 02_raw_data.sql first;
-- they create RAW and load the synthetic SAP data this script clones.
EXECUTE IMMEDIATE $$
DECLARE
  missing_source EXCEPTION (-20001, 'RAW.LFA1 not found. Run sql/01_setup.sql and sql/02_raw_data.sql first.');
BEGIN
  IF (NOT EXISTS (SELECT 1 FROM SENSE_ONTOLOGY_QS.INFORMATION_SCHEMA.TABLES
                  WHERE TABLE_SCHEMA = 'RAW' AND TABLE_NAME = 'LFA1')) THEN
    RAISE missing_source;
  END IF;
  RETURN 'RAW source tables found';
END;
$$;

EXECUTE IMMEDIATE $$
DECLARE
  t ARRAY DEFAULT ARRAY_CONSTRUCT('LFA1','LFA2','LFB1','MARA','EKPO','LIKP','T001W','T320',
                                  'STPO','QALS','BSEG','COEP','VBAP','KONV','QUAL_MATRIX');
  i INTEGER DEFAULT 0;
  n VARCHAR;
BEGIN
  FOR i IN 0 TO ARRAY_SIZE(t)-1 DO
    n := t[i];
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TABLE SENSE_ONTOLOGY_QS.SAP.' || n ||
                      ' CLONE SENSE_ONTOLOGY_QS.RAW.' || n;
  END FOR;
  RETURN 'cloned ' || ARRAY_SIZE(t);
END;
$$;

-- Reference (code) tables: BON holds one term per code field that points here.
-- New codes arrive via normal ETL into these tables; BON only changes when a rule changes.
CREATE OR REPLACE TABLE T077K (
  KTOKK VARCHAR(10) PRIMARY KEY COMMENT 'Vendor account group code',
  TXT30 VARCHAR(60) COMMENT 'Account group description',
  EXCLUDE_FROM_ACTIVE_COUNT BOOLEAN COMMENT 'TRUE if vendors in this group are excluded from the active supplier count'
) COMMENT = 'Vendor account group reference (code table)' AS
SELECT * FROM VALUES ('ZSTR','Strategic partner',FALSE),('ZSTD','Standard vendor',FALSE),('ZPRB','Probationary vendor',TRUE);

CREATE OR REPLACE TABLE T023T (
  MATKL VARCHAR(5) PRIMARY KEY COMMENT 'Material group code',
  WGBEZ VARCHAR(60) COMMENT 'Material group description'
) COMMENT = 'Material group texts (code table)' AS
SELECT * FROM VALUES ('043','Electronics'),('044','Chemicals'),('045','Metals'),('046','Packaging'),('047','Raw Materials'),('048','Assembly');

-- Procurement semantic view: tables, keys, joins and labels only. No metrics, synonyms or business rules.
CREATE OR REPLACE SEMANTIC VIEW PROCUREMENT_BARE_SV
TABLES (
  LFA1 AS SENSE_ONTOLOGY_QS.SAP.LFA1 PRIMARY KEY (LIFNR) COMMENT = 'Vendor master data',
  T077K AS SENSE_ONTOLOGY_QS.SAP.T077K PRIMARY KEY (KTOKK) COMMENT = 'Vendor account groups',
  LFB1 AS SENSE_ONTOLOGY_QS.SAP.LFB1 PRIMARY KEY (LIFNR, VKONT) COMMENT = 'Vendor contract data',
  MARA AS SENSE_ONTOLOGY_QS.SAP.MARA PRIMARY KEY (MATNR) COMMENT = 'Material master data',
  T023T AS SENSE_ONTOLOGY_QS.SAP.T023T PRIMARY KEY (MATKL) COMMENT = 'Material group texts',
  EKPO AS SENSE_ONTOLOGY_QS.SAP.EKPO PRIMARY KEY (EBELN, EBELP) COMMENT = 'Purchasing document items',
  T001W AS SENSE_ONTOLOGY_QS.SAP.T001W PRIMARY KEY (WERKS) COMMENT = 'Plant data',
  LIKP AS SENSE_ONTOLOGY_QS.SAP.LIKP PRIMARY KEY (TKNUM) COMMENT = 'Shipment data',
  LFA2 AS SENSE_ONTOLOGY_QS.SAP.LFA2 PRIMARY KEY (TDLNR) COMMENT = 'Forwarding agent data',
  QALS AS SENSE_ONTOLOGY_QS.SAP.QALS PRIMARY KEY (PRUEFLOS) COMMENT = 'Inspection lot data',
  STPO AS SENSE_ONTOLOGY_QS.SAP.STPO PRIMARY KEY (STLNR, IDNRK) COMMENT = 'BOM items'
)
RELATIONSHIPS (
  LFA1 (KTOKK) REFERENCES T077K,
  MARA (MATKL) REFERENCES T023T,
  LFB1 (LIFNR) REFERENCES LFA1,
  EKPO (LIFNR) REFERENCES LFA1,
  EKPO (MATNR) REFERENCES MARA,
  EKPO (WERKS) REFERENCES T001W,
  LIKP (TDLNR) REFERENCES LFA2,
  LIKP (WERKS_DST) REFERENCES T001W,
  QALS (MATNR) REFERENCES MARA,
  STPO (IDNRK) REFERENCES MARA
)
FACTS (
  MARA.STPRS AS STPRS COMMENT = 'Standard price',
  EKPO.NETWR AS NETWR COMMENT = 'Net order value',
  EKPO.MENGE AS MENGE COMMENT = 'Purchase order quantity',
  LIKP.MENGE AS MENGE COMMENT = 'Delivery quantity',
  LIKP.FRTCO AS FRTCO COMMENT = 'Freight cost',
  LFA2.OTRAT AS OTRAT COMMENT = 'Carrier on-time ratio',
  LFA2.LZEIT AS LZEIT COMMENT = 'Transit time',
  QALS.QAESSION AS QAESSION COMMENT = 'Defect rate',
  LFB1.JWERT AS JWERT COMMENT = 'Annual contract value',
  STPO.MENGE AS MENGE COMMENT = 'Component quantity',
  STPO.STUFE AS STUFE COMMENT = 'BOM level'
)
DIMENSIONS (
  LFA1.LIFNR AS LIFNR COMMENT = 'Vendor number', LFA1.NAME1 AS NAME1 COMMENT = 'Vendor name', LFA1.ORT01 AS ORT01 COMMENT = 'City', LFA1.LAND1 AS LAND1 COMMENT = 'Country code', LFA1.KTOKK AS KTOKK COMMENT = 'Account group', LFA1.ZTERM AS ZTERM COMMENT = 'Payment terms key',
  T077K.KTOKK AS KTOKK COMMENT = 'Account group', T077K.TXT30 AS TXT30 COMMENT = 'Description', T077K.EXCLUDE_FROM_ACTIVE_COUNT AS EXCLUDE_FROM_ACTIVE_COUNT COMMENT = 'Exclude flag',
  LFB1.VKONT AS VKONT COMMENT = 'Contract account', LFB1.VTART AS VTART COMMENT = 'Contract type', LFB1.DTEND AS DTEND COMMENT = 'Validity end date',
  MARA.MATNR AS MATNR COMMENT = 'Material number', MARA.MAKTX AS MAKTX COMMENT = 'Material description', MARA.MATKL AS MATKL COMMENT = 'Material group',
  T023T.WGBEZ AS WGBEZ COMMENT = 'Material group description',
  EKPO.EBELN AS EBELN COMMENT = 'Purchasing document number', EKPO.EBELP AS EBELP COMMENT = 'Item number', EKPO.LIFNR AS LIFNR COMMENT = 'Vendor number', EKPO.MATNR AS MATNR COMMENT = 'Material number', EKPO.WERKS AS WERKS COMMENT = 'Plant', EKPO.STATU AS STATU COMMENT = 'Status', EKPO.BEDAT AS BEDAT COMMENT = 'Purchasing document date',
  T001W.WERKS AS WERKS COMMENT = 'Plant', T001W.NAME1 AS NAME1 COMMENT = 'Name', T001W.REGIO AS REGIO COMMENT = 'Region',
  LIKP.TKNUM AS TKNUM COMMENT = 'Shipment number', LIKP.TDLNR AS TDLNR COMMENT = 'Forwarding agent', LIKP.MATNR AS MATNR COMMENT = 'Material number', LIKP.STATU AS STATU COMMENT = 'Delivery status', LIKP.LFDAT AS LFDAT COMMENT = 'Delivery date', LIKP.WADAT AS WADAT COMMENT = 'Goods issue date', LIKP.WERKS_DST AS WERKS_DST COMMENT = 'Destination plant',
  LFA2.TDLNR AS TDLNR COMMENT = 'Forwarding agent', LFA2.NAME1 AS NAME1 COMMENT = 'Name', LFA2.VSART AS VSART COMMENT = 'Shipping type',
  QALS.PRUEFLOS AS PRUEFLOS COMMENT = 'Inspection lot', QALS.MATNR AS MATNR COMMENT = 'Material number', QALS.VCODE AS VCODE COMMENT = 'Usage decision code',
  STPO.STLNR AS STLNR COMMENT = 'Bill of material', STPO.IDNRK AS IDNRK COMMENT = 'BOM component'
)
COMMENT = 'SAP procurement data: vendors, materials, purchase orders, shipments, carriers, inspections, BOM';
SENSE_FILE_SQL_03_SAP_SCHEMA_SQL

cat > 'sql/04_domain.sql' <<'SENSE_FILE_SQL_04_DOMAIN_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

SELECT SYSTEM$CREATE_GLOSSARY_DOMAIN('Sense Quickstart Procurement', 'Governed procurement concepts for the Cortex Sense and Business Ontology quickstart: suppliers, purchase orders, shipments and carriers. Steward: Procurement data steward.');
SENSE_FILE_SQL_04_DOMAIN_SQL

cat > 'sql/05_nodes.sql' <<'SENSE_FILE_SQL_05_NODES_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Supplier", "domainName": "Sense Quickstart Procurement", "itemKind": "ENTITY", "synonyms": ["Vendor", "Supply partner"], "description": "A company we buy materials from, recorded in the vendor master (LFA1). Each supplier has an account group (KTOKK) that decides whether it counts as an active supplier."}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Material", "domainName": "Sense Quickstart Procurement", "itemKind": "ENTITY", "synonyms": ["Part", "Component"], "description": "A purchased item in the material master (MARA), identified by MATNR and grouped by material group (MATKL)."}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Purchase Order", "domainName": "Sense Quickstart Procurement", "itemKind": "ENTITY", "synonyms": ["PO", "PO line"], "description": "An order line placed with a supplier for a material (EKPO). Its net value (NETWR) is procurement spend."}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Shipment", "domainName": "Sense Quickstart Procurement", "itemKind": "ENTITY", "synonyms": ["Delivery", "Inbound shipment"], "description": "An inbound delivery (LIKP) with a planned delivery date (LFDAT), an actual goods issue date (WADAT), and a status (D delivered, T in transit, X cancelled)."}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Carrier", "domainName": "Sense Quickstart Procurement", "itemKind": "ENTITY", "synonyms": ["Forwarding agent", "Logistics provider"], "description": "A logistics provider that moves shipments (LFA2). Carriers self-report an on-time ratio (OTRAT), which is not the official on-time measure."}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Vendor Account Group", "domainName": "Sense Quickstart Procurement", "itemKind": "TERM", "synonyms": ["KTOKK", "Vendor type"], "description": "Code field KTOKK on the vendor master that classifies suppliers: ZSTR = strategic partner, ZSTD = standard vendor, ZPRB = probationary. The full code list and the EXCLUDE_FROM_ACTIVE_COUNT flag live in reference table T077K; new codes are added there, not here."}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Probationary Vendor Exclusion", "domainName": "Sense Quickstart Procurement", "itemKind": "POLICY_CONCEPT", "synonyms": [], "description": "Procurement policy: vendors in a probationary account group (ZPRB, flagged EXCLUDE_FROM_ACTIVE_COUNT in T077K) are not active suppliers. They are excluded from supplier counts and supplier KPIs until promoted."}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Supplier Count", "synonyms": ["Number of suppliers", "Active suppliers", "Active supplier count"], "description": "Official supplier count used in all reporting: the number of active suppliers, meaning vendors in account group ZSTR (strategic) or ZSTD (standard). Probationary vendors (ZPRB) are excluded by procurement policy. The vendor master holds every vendor record, so counting LFA1 rows overstates the supplier count.", "formula": "COUNT(DISTINCT LIFNR) WHERE KTOKK IN (ZSTR, ZSTD)", "exclusions": ["KTOKK = ZPRB (probationary)"], "formulaSource": "SENSE_ONTOLOGY_QS.SAP.LFA1", "domainName": "Sense Quickstart Procurement", "itemKind": "METRIC"}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Vendor Record Count", "scope": "Procurement operations", "synonyms": ["Vendor master record count"], "description": "Operational variant of Supplier Count: every vendor record on file, including probationary vendors. Use it only for vendor master data maintenance, never as the supplier count.", "formula": "COUNT(DISTINCT LIFNR)", "formulaSource": "SENSE_ONTOLOGY_QS.SAP.LFA1", "domainName": "Sense Quickstart Procurement", "itemKind": "METRIC"}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "On-Time Delivery Rate", "synonyms": ["OTD", "On-time delivery", "Delivery performance"], "description": "Official on-time delivery rate: percent of delivered shipments (status D) whose actual goods issue date (WADAT) is on or before the planned delivery date (LFDAT). The carrier self-reported ratio (OTRAT) is not the official measure.", "formula": "100 * COUNT(WADAT <= LFDAT) / COUNT(*) WHERE STATU = D", "formulaSource": "SENSE_ONTOLOGY_QS.SAP.LIKP", "domainName": "Sense Quickstart Procurement", "itemKind": "METRIC"}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Carrier Reported On-Time Rate", "scope": "Carrier scorecard", "synonyms": ["OTRAT", "Carrier OTD"], "description": "Variant of On-Time Delivery Rate: the average on-time ratio self-reported by carriers. Useful for carrier negotiations only, never as delivery performance.", "formula": "AVG(OTRAT) * 100", "formulaSource": "SENSE_ONTOLOGY_QS.SAP.LFA2", "domainName": "Sense Quickstart Procurement", "itemKind": "METRIC"}');
SELECT SYSTEM$DRAFT_GLOSSARY_TERM('{"name": "Procurement Spend", "synonyms": ["Purchase spend", "Spend"], "description": "Total net value of purchase order lines (EKPO NETWR). It includes every supplier, so it is the right figure for total spend and the wrong one for spend with active suppliers only.", "formula": "SUM(NETWR)", "formulaSource": "SENSE_ONTOLOGY_QS.SAP.EKPO", "domainName": "Sense Quickstart Procurement", "itemKind": "METRIC"}');
SENSE_FILE_SQL_05_NODES_SQL

cat > 'sql/06_approve.sql' <<'SENSE_FILE_SQL_06_APPROVE_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

SELECT SYSTEM$APPROVE_ALL_GLOSSARY_TERMS('[]', 'ACTIVE', '{"sessionId":"CURRENT_SESSION"}');
SENSE_FILE_SQL_06_APPROVE_SQL

cat > 'sql/07_relationships.sql' <<'SENSE_FILE_SQL_07_RELATIONSHIPS_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Purchase Order','Sense Quickstart Procurement.Supplier','RELATED_TO');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Purchase Order','Sense Quickstart Procurement.Material','RELATED_TO');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Carrier','Sense Quickstart Procurement.Shipment','RELATED_TO');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Supplier Count','Sense Quickstart Procurement.Supplier','MEASURES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Supplier Count','Sense Quickstart Procurement.Vendor Record Count','HAS_VARIANT');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.On-Time Delivery Rate','Sense Quickstart Procurement.Shipment','MEASURES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.On-Time Delivery Rate','Sense Quickstart Procurement.Carrier Reported On-Time Rate','HAS_VARIANT');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Carrier Reported On-Time Rate','Sense Quickstart Procurement.Carrier','MEASURES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Procurement Spend','Sense Quickstart Procurement.Purchase Order','MEASURES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Vendor Account Group','Sense Quickstart Procurement.Supplier','CLASSIFIES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Probationary Vendor Exclusion','Sense Quickstart Procurement.Supplier Count','APPLIES_TO');
SENSE_FILE_SQL_07_RELATIONSHIPS_SQL

cat > 'sql/08_representations.sql' <<'SENSE_FILE_SQL_08_REPRESENTATIONS_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Supplier', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.LFA1", "objectName": "LFA1"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Material', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.MARA", "objectName": "MARA"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Purchase Order', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.EKPO", "objectName": "EKPO"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Shipment', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.LIKP", "objectName": "LIKP"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Carrier', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.LFA2", "objectName": "LFA2"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Vendor Account Group', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.T077K", "objectName": "T077K"}', 'REFERENCE_DATA');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Supplier Count', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Vendor Record Count', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.On-Time Delivery Rate', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Carrier Reported On-Time Rate', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Procurement Spend', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SENSE_FILE_SQL_08_REPRESENTATIONS_SQL

cat > 'sql/09_agents.sql' <<'SENSE_FILE_SQL_09_AGENTS_SQL'
-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

CREATE OR REPLACE AGENT SENSE_ONTOLOGY_QS.SAP.BARE_AGENT
  COMMENT = 'Quickstart arm A: bare procurement semantic view only'
  FROM SPECIFICATION $$
models:
  orchestration: auto
orchestration:
  budget:
    seconds: 150
    tokens: 40000
instructions:
  response: |
    You are an analytics assistant for SAP procurement data.
    Answer precisely. State the final answer as a clear number or list first,
    then briefly explain how it was computed and which data was used.
    Never write your planning or reasoning notes in the response; write only the final answer.
  orchestration: |
    Use query_procurement for every data question. It queries one semantic view
    over vendors, materials, purchase orders, shipments, carriers and inspections.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_procurement
      description: Procurement data - vendors, materials, purchase orders, shipments, carriers, inspections.
tool_resources:
  query_procurement:
    semantic_view: SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
$$;

CREATE OR REPLACE AGENT SENSE_ONTOLOGY_QS.SAP.ONTOLOGY_AGENT
  COMMENT = 'Quickstart arm B: bare semantic view plus Business Ontology search'
  FROM SPECIFICATION $$
models:
  orchestration: auto
experimental:
  EnableSnowscopeBusinessOntologySearch: true
orchestration:
  budget:
    seconds: 150
    tokens: 40000
instructions:
  response: |
    You are an analytics assistant for SAP procurement data.
    Answer precisely. State the final answer as a clear number or list first,
    then briefly explain how it was computed and which data was used.
    Never write your planning or reasoning notes in the response; write only the final answer.
    When you used a governed Business Ontology definition, name the term.
  orchestration: |
    Before querying data, call business_ontology to look up the governed
    definition of each business term in the question. When the ontology names a
    canonical metric, use its formula rather than a similarly named variant, and
    follow any policy that applies to it. Then use query_procurement to compute it.
    If the question only asks what something means, answer from the ontology.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_procurement
      description: Procurement data - vendors, materials, purchase orders, shipments, carriers, inspections.
  - tool_spec:
      type: snowscope_search
      name: business_ontology
      description: Governed business definitions for procurement - canonical metrics and their formulas, scoped variants, business policies, and code meanings.
tool_resources:
  query_procurement:
    semantic_view: SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
  business_ontology:
    corpus: businessOntology
$$;

CREATE OR REPLACE AGENT SENSE_ONTOLOGY_QS.SAP.SENSE_AGENT
  COMMENT = 'Quickstart arm C: bare semantic view plus Cortex Sense context'
  FROM SPECIFICATION $$
models:
  orchestration: auto
experimental:
  AgenticAnalystAllowArbitrarySQL: true
  FallbackWarehouse: SENSE_ONTOLOGY_QS_WH
orchestration:
  budget:
    seconds: 150
    tokens: 40000
instructions:
  response: |
    You are an analytics assistant for SAP procurement data.
    Answer precisely. State the final answer as a clear number or list first,
    then briefly explain how it was computed and which data was used.
    Never write your planning or reasoning notes in the response; write only the final answer.
  orchestration: |
    Before querying data, call procurement_context to retrieve what Cortex Sense
    learned about these tables: how they join, which columns matter, and the
    queries people already run. Use it to choose tables and write SQL. Then use
    query_procurement for questions the semantic view covers.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_procurement
      description: Procurement data - vendors, materials, purchase orders, shipments, carriers, inspections.
  - tool_spec:
      type: cortex_sense
      name: procurement_context
      description: Usage-derived context for the SAP procurement tables - joins, key columns, and example queries people already run.
tool_resources:
  query_procurement:
    semantic_view: SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
  procurement_context:
    context_name: SENSE_ONTOLOGY_QS.SAP.SENSE_QS_TABLES
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
$$;

CREATE OR REPLACE AGENT SENSE_ONTOLOGY_QS.SAP.SENSE_ONTOLOGY_AGENT
  COMMENT = 'Quickstart arm D: bare semantic view plus Cortex Sense and Business Ontology'
  FROM SPECIFICATION $$
models:
  orchestration: auto
experimental:
  EnableSnowscopeBusinessOntologySearch: true
  AgenticAnalystAllowArbitrarySQL: true
  FallbackWarehouse: SENSE_ONTOLOGY_QS_WH
orchestration:
  budget:
    seconds: 150
    tokens: 40000
instructions:
  response: |
    You are an analytics assistant for SAP procurement data.
    Answer precisely. State the final answer as a clear number or list first,
    then briefly explain how it was computed and which data was used.
    Never write your planning or reasoning notes in the response; write only the final answer.
    When you used a governed Business Ontology definition, name the term.
  orchestration: |
    Before querying data, call business_ontology to look up the governed
    definition of each business term in the question, and call procurement_context
    to retrieve how the tables join and which queries people already run. When the
    ontology names a canonical metric, use its formula rather than a similarly
    named variant, and follow any policy that applies to it. Then use
    query_procurement for questions the semantic view covers.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_procurement
      description: Procurement data - vendors, materials, purchase orders, shipments, carriers, inspections.
  - tool_spec:
      type: snowscope_search
      name: business_ontology
      description: Governed business definitions for procurement - canonical metrics and their formulas, scoped variants, business policies, and code meanings.
  - tool_spec:
      type: cortex_sense
      name: procurement_context
      description: Usage-derived context for the SAP procurement tables - joins, key columns, and example queries people already run.
tool_resources:
  query_procurement:
    semantic_view: SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
  business_ontology:
    corpus: businessOntology
  procurement_context:
    context_name: SENSE_ONTOLOGY_QS.SAP.SENSE_QS_FULL
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
$$;
SENSE_FILE_SQL_09_AGENTS_SQL

cat > 'eval/run_eval.py' <<'SENSE_FILE_EVAL_RUN_EVAL_PY'
#!/usr/bin/env python3
"""Compare four Cortex Agents on a fixed question set and print a scorecard.

Arms: A bare semantic view, B + Business Ontology, C + Cortex Sense (tables only),
D + Business Ontology + Cortex Sense. Each answer is graded by an LLM judge against
the expected value in questions.csv.

Environment:
  SNOWFLAKE_CONNECTION_NAME  connection to use (default: "default")
  SNOWFLAKE_ROLE, SNOWFLAKE_WAREHOUSE  optional overrides
  SENSE_ONTOLOGY_SCHEMA  schema that holds the agents (default: SENSE_ONTOLOGY_QS.SAP)
  JUDGE_MODEL  model for grading (default: claude-sonnet-4-5)
"""
import argparse
import concurrent.futures as cf
import csv
import json
import math
import os
import re
import threading
import time

import snowflake.connector

SCHEMA = os.environ.get("SENSE_ONTOLOGY_SCHEMA", "SENSE_ONTOLOGY_QS.SAP")
JUDGE_MODEL = os.environ.get("JUDGE_MODEL", "claude-sonnet-4-5")
ARMS = {"A": "BARE_AGENT", "B": "ONTOLOGY_AGENT", "C": "SENSE_AGENT", "D": "SENSE_ONTOLOGY_AGENT"}
HERE = os.path.dirname(os.path.abspath(__file__))

JUDGE_PROMPT = """You grade an analytics agent's answer against ground truth.
Question: {question}
Expected: {expected}
Plausible wrong answer: {wrong}
Agent answer:
<<<
{answer}
>>>
The headline number must match the expected value within rounding. If the agent offers competing answers and never says which one is official, it is hedged and NOT correct.
Return only JSON with keys: "headline" (the final number the agent gave), "hedged" (true/false), "correct" (true/false), "reason" (one short sentence)."""


_CONN = None
_LOCK = threading.Lock()


def connect(fresh=False):
    """One shared connection, so browser or SSO logins prompt once, not once per call."""
    global _CONN
    with _LOCK:
        if _CONN is None or fresh:
            overrides = {k: os.environ[e] for k, e in (("role", "SNOWFLAKE_ROLE"), ("warehouse", "SNOWFLAKE_WAREHOUSE")) if os.environ.get(e)}
            _CONN = snowflake.connector.connect(connection_name=os.environ.get("SNOWFLAKE_CONNECTION_NAME", "default"), **overrides)
        return _CONN


def run_agent(agent, question, tries=3):
    body = json.dumps({"messages": [{"role": "user", "content": [{"type": "text", "text": question}]}]})
    err = ""
    for attempt in range(tries):
        try:
            cur = connect(fresh=attempt > 0).cursor()
            cur.execute("SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(%s, %s)", (f"{SCHEMA}.{agent}", body))
            resp = json.loads(cur.fetchone()[0])
            content = resp.get("content", [])
            return {
                "tools": [c["tool_use"]["name"] for c in content if c.get("type") == "tool_use"],
                "answer": "\n".join(c.get("text", "") for c in content if c.get("type") == "text" and c.get("text", "").strip()),
                "error": None,
            }
        except Exception as exc:  # a connection or service error is retried, never scored as a wrong answer
            err = str(exc)[:300]
            time.sleep(10 * (attempt + 1))
    return {"tools": [], "answer": "", "error": err}


def judge(q, answer):
    try:
        cur = connect().cursor()
        prompt = JUDGE_PROMPT.format(question=q["question"], expected=q["expected"], wrong=q["wrong"], answer=answer[:5000])
        for _ in range(3):
            try:
                cur.execute("SELECT AI_COMPLETE(%s, %s)", (JUDGE_MODEL, prompt))
                raw = cur.fetchone()[0]
                if raw.lstrip().startswith('"'):
                    raw = json.loads(raw)
                return json.loads(re.search(r"\{.*\}", raw, re.S).group(0))
            except Exception:
                time.sleep(5)
        return {"correct": None, "reason": "judge failed"}
    except Exception as exc:
        return {"correct": None, "reason": str(exc)[:200]}


def one(arm, q, rep):
    r = run_agent(ARMS[arm], q["question"])
    v = {"correct": None, "reason": r["error"]} if r["error"] else judge(q, r["answer"])
    return {"arm": arm, "qid": q["id"], "category": q["category"], "rep": rep, "tools": r["tools"], "answer": r["answer"], "correct": v.get("correct"), "reason": v.get("reason")}


def scorecard(rows):
    cats = ["governed", "discovery", "control"]
    print(f"\n{'Arm':<24}" + "".join(f"{c:>12}" for c in cats) + f"{'total':>10}")
    for a in "ABCD":
        mine = [r for r in rows if r["arm"] == a]
        if not mine:
            continue
        cells = []
        for c in cats:
            rs = [r for r in mine if r["category"] == c]
            cells.append(f"{sum(1 for r in rs if r['correct'])}/{len(rs)}")
        print(f"{a} {ARMS[a]:<22}" + "".join(f"{x:>12}" for x in cells) + f"{sum(1 for r in mine if r['correct'])}/{len(mine)}".rjust(10))
    unscored = sum(1 for r in rows if r["correct"] is None)
    if unscored:
        print(f"\n{unscored} runs have no verdict (service or judge error). Rerun with --resume.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--arms", default="A,B,C,D")
    ap.add_argument("--reps", type=int, default=2)
    ap.add_argument("--qids", default="", help="comma-separated question ids, default all")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--out", default=os.path.join(HERE, "results.json"))
    ap.add_argument("--resume", action="store_true", help="run only the calls that have no verdict yet")
    args = ap.parse_args()
    qs = [q for q in csv.DictReader(open(os.path.join(HERE, "questions.csv"))) if not args.qids or q["id"] in args.qids.split(",")]
    rows = json.load(open(args.out)) if args.resume and os.path.exists(args.out) else []
    done = {(r["arm"], r["qid"], r["rep"]) for r in rows if r["correct"] is not None}
    rows = [r for r in rows if r["correct"] is not None]
    jobs = [(a, q, i) for a in args.arms.split(",") for q in qs for i in range(args.reps) if (a, q["id"], i) not in done]
    print(f"Running {len(jobs)} calls on {SCHEMA} ...", flush=True)
    with cf.ThreadPoolExecutor(args.workers) as ex:
        for res in ex.map(lambda j: one(*j), jobs):
            rows.append(res)
            print(res["arm"], res["qid"], res["rep"], res["correct"], res["tools"], flush=True)
            json.dump(rows, open(args.out, "w"), indent=1)
    scorecard(rows)


if __name__ == "__main__":
    main()
SENSE_FILE_EVAL_RUN_EVAL_PY

cat > 'eval/questions.csv' <<'SENSE_FILE_EVAL_QUESTIONS_CSV'
id,category,question,expected,wrong
V01,governed,How many suppliers do we have?,14,15
V02,governed,What is our on-time delivery rate?,66.67,90
V03,governed,What is the carrier-reported on-time rate?,90,66.67
V04,governed,How many shipments are included in the calculation of our official on-time delivery rate?,15,20
V05,governed,What percent of total procurement spend goes to suppliers that are not active?,1.66,0
V06,governed,How many active suppliers are in Mexico?,1,2
V07,governed,What is the on-time delivery rate for TransGlobal Freight?,0,87
V08,governed,What is our procurement spend with strategic suppliers?,251690,1353690
V09,governed,What percentage of vendor records are active suppliers?,93.33,100
V10,governed,What is the on-time delivery rate for shipments carried by carriers whose self-reported on-time rate is above 90 percent?,75,93.67
V11,discovery,How many distinct vendors have an APPROVED qualification in the qualification matrix?,12,0
V12,discovery,How many qualification records are still PENDING?,2,0
V13,discovery,How many vendors have an approved qualification but are missing from the vendor master?,11,0
V14,discovery,What is the total cost posted to cost object KS-MFG-US?,419750,0
V15,discovery,What is the total amount of accounts payable postings with posting key 31?,1606190,0
V16,discovery,What is the total net value of all sales order lines?,746000,0
V17,discovery,How many pricing condition records have condition type K007?,8,0
V18,discovery,What is the total storage capacity across all storage locations?,558,0
V19,discovery,How many storage locations belong to plant PLT-001?,3,0
V20,discovery,How many distinct customers appear on sales order lines?,5,0
V21,control,How many materials are in the material master?,24,0
V22,control,How many plants do we have?,5,0
V23,control,How many carriers do we use?,6,0
V24,control,How many purchase order lines are there?,25,0
V25,control,How many inspection lots are there?,10,0
V26,control,What is the average carrier transit time in days?,13.5,0
V27,control,How many shipments are still in transit?,3,0
V28,control,What is the total delivered quantity across delivered shipments?,279300,0
V29,control,How many distinct materials have been ordered on purchase orders?,17,0
V30,control,What is the largest single purchase order line net value?,97500,0
SENSE_FILE_EVAL_QUESTIONS_CSV

files=(
  'sql/01_setup.sql'
  'sql/02_raw_data.sql'
  'sql/03_sap_schema.sql'
  'sql/04_domain.sql'
  'sql/05_nodes.sql'
  'sql/06_approve.sql'
  'sql/07_relationships.sql'
  'sql/08_representations.sql'
  'sql/09_agents.sql'
  'eval/run_eval.py'
  'eval/questions.csv'
)
for file in "${files[@]}"; do
  if [[ ! -s "$file" ]]; then
    printf 'Setup failed: missing or empty file: %s\n' "$file" >&2
    exit 1
  fi
done
printf '%s\n' \
  'Created 11 project files in sense-ontology/getting-started.' \
  'No Snowflake statements or agent calls were executed.'
SENSE_BOOTSTRAP
