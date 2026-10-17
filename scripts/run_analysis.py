"""python scripts/run_analysis.py — Python 3.10+, только стандартная библиотека."""
from pathlib import Path
import csv,json,sqlite3,statistics
ROOT=Path(__file__).resolve().parents[1]

def main():
    db=sqlite3.connect(':memory:');db.row_factory=sqlite3.Row
    db.executescript((ROOT/'sql/00_schema.sql').read_text(encoding='utf-8'))
    sources={}
    for name in ['orders','products_category','order_items']:
        with (ROOT/'data'/f'{name}.csv').open(encoding='utf-8',newline='') as f:
            reader=csv.DictReader(f);cols=reader.fieldnames;rows=list(reader)
        sources[name]=rows
        values=[[None if r[c]=='' else r[c] for c in cols] for r in rows]
        db.executemany(f'INSERT INTO {name} VALUES ({",".join("?" for _ in cols)})',values)
    assert not db.execute('PRAGMA foreign_key_check').fetchall()
    results={};(ROOT/'outputs').mkdir(exist_ok=True)
    for path in sorted((ROOT/'sql').glob('*.sql')):
        if path.name.startswith('00_'):continue
        rs=[dict(r) for r in db.execute(path.read_text(encoding='utf-8'))]
        results[path.stem]=rs
        with (ROOT/'outputs'/f'{path.stem}.csv').open('w',encoding='utf-8-sig',newline='') as f:
            writer=csv.DictWriter(f,fieldnames=rs[0]);writer.writeheader();writer.writerows(rs)
    # Независимые проверки без JOIN/SQL: множества и statistics.
    from datetime import datetime
    orders=sources['orders'];items=sources['order_items']
    days=[(datetime.fromisoformat(o['delivered_customer_date'])-datetime.fromisoformat(o['purchase_timestamp'])).days for o in orders if o['delivered_customer_date']]
    assert results['02_orders'][0]['orders_count']==len(orders)==45101
    assert results['03_july_customers'][0]['july_customers']==len({o['customer_id'] for o in orders if '2017-07-01'<=o['purchase_timestamp']<'2017-08-01'})==3947
    assert abs(results['04_delivery'][0]['mean_days']-statistics.mean(days))<1e-10
    q2={o['order_id'] for o in orders if '2017-04-01'<=o['purchase_timestamp']<'2017-07-01'}
    ii=[i for i in items if i['order_id'] in q2]
    assert results['06_q2_sku'][0]['q2_unique_sku']==len({i['product_id'] for i in ii})==4762
    assert abs(results['07_q2_price'][0]['mean_unit_price']-statistics.mean(float(i['price']) for i in ii))<1e-8
    cats={p['product_id']:p['product_category_name'] for p in sources['products_category']}
    groups={}
    for i in items:groups.setdefault(cats[i['product_id']],set()).add(i['order_id'])
    ranked=sorted([(c,len(v)) for c,v in groups.items() if c],key=lambda x:(-x[1],x[0]))
    assert results['08_seventh_category'][0]['product_category_name']==ranked[6][0]=='toys'
    a,b=groups['bed_bath_table'],groups['computers_accessories']
    assert results['09_category_union'][0]['either_orders']==len(a|b)==7120
    assert results['09_category_union'][0]['both_orders']==len(a&b)==1
    percentiles={r['metric']:r['days'] for r in results['05_delivery_distribution']}
    assert percentiles['median']==statistics.median(days)
    assert percentiles['P90']==statistics.quantiles(days,n=100,method='inclusive')[89]
    # Полуоткрытые границы квартала: 01.04 включён, 01.07 исключён.
    assert '2017-04-01'<='2017-04-01T00:00:00'<'2017-07-01'
    assert not ('2017-04-01'<='2017-07-01T00:00:00'<'2017-07-01')
    (ROOT/'outputs/sql_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
    print('Все 9 SQL-запросов выполнены. Проверки ключей, связей, метрик, перцентилей и дат пройдены.')
    for k,v in results.items():print(k, json.dumps(v,ensure_ascii=False))
if __name__=='__main__':main()
