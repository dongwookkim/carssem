#!/usr/bin/env python3
"""
법정동코드 텍스트 파일(EUC-KR)을 읽어 regions 테이블 INSERT SQL을 생성한다.
- 폐지 항목 제외
- 읍/면/동/리 단위만 추출 (3~4 단어)
- 출력: supabase/migrations/004_regions_seed.sql
"""

import os

INPUT = os.path.join(os.path.dirname(__file__), '..', 'ko-address.txt')
OUTPUT = os.path.join(os.path.dirname(__file__), '..', 'supabase', 'migrations', '004_regions_seed.sql')

BATCH_SIZE = 500  # INSERT 당 행 수


def escape_sql(s: str) -> str:
    return s.replace("'", "''")


def main():
    rows = []

    with open(INPUT, 'r', encoding='euc-kr') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split('\t')
            if len(parts) < 3:
                continue

            status = parts[2].strip()
            if status != '존재':
                continue

            full_name = parts[1].strip()
            words = full_name.split()

            # 3단어: 시도 시군구 읍면동
            # 4단어: 시도 시군구 읍면 리
            if len(words) < 3:
                continue

            sido = words[0]
            sigungu = words[1]
            # 나머지를 eupmyeondong으로
            eupmyeondong = ' '.join(words[2:])

            rows.append((sido, sigungu, eupmyeondong, full_name))

    print(f'Total rows: {len(rows)}')

    with open(OUTPUT, 'w', encoding='utf-8') as f:
        f.write('-- Auto-generated: 법정동 시드 데이터\n')
        f.write('-- Source: 행정안전부 법정동코드 전체자료\n\n')

        for i in range(0, len(rows), BATCH_SIZE):
            batch = rows[i:i + BATCH_SIZE]
            f.write('INSERT INTO regions (sido, sigungu, eupmyeondong, full_name) VALUES\n')
            values = []
            for sido, sigungu, eupmyeondong, full_name in batch:
                values.append(
                    f"  ('{escape_sql(sido)}', '{escape_sql(sigungu)}', "
                    f"'{escape_sql(eupmyeondong)}', '{escape_sql(full_name)}')"
                )
            f.write(',\n'.join(values))
            f.write(';\n\n')

    print(f'Written to {OUTPUT}')


if __name__ == '__main__':
    main()
