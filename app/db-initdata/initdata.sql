-- AWS認定資格のテーブルを作成
CREATE TABLE IF NOT EXISTS aws_certifications (
    No INT AUTO_INCREMENT PRIMARY KEY,
    Abbreviation VARCHAR(100),
    OfficialName VARCHAR(100)
) CHARSET=utf8mb4;

-- テーブルが既に存在する場合は一旦全てのレコードを削除（TRUNCATE:切り捨て）
TRUNCATE TABLE aws_certifications;

-- aws_certificationsテーブルに12レコード追加
INSERT INTO aws_certifications (Abbreviation, OfficialName) VALUES
    ('CLF', 'AWS Certified Cloud Practitioner - Foundational'),
    ('AIF', 'AWS Certified AI Practitioner - Foundational'),
    ('SAA', 'AWS Certified Solutions Architect - Associate'),
    ('DVA', 'AWS Certified Developer - Associate'),
    ('SOA', 'AWS Certified SysOps Administrator - Associate'),
    ('MLA', 'AWS Certified Machine Learning Engineer - Associate'),
    ('DEA', 'AWS Certified Data Engineer - Associate'),
    ('SAP', 'AWS Certified Solutions Architect - Professional'),
    ('DOP', 'AWS Certified DevOps Engineer - Professional'),
    ('ANS', 'AWS Certified Advanced Networking - Specialty'),
    ('MLS', 'AWS Certified Machine Learning - Specialty'),
    ('SCS', 'AWS Certified Security - Specialty');

-- テーブルのレコード件数を確認
SELECT COUNT(*) AS total_records FROM aws_certifications;