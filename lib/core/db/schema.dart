/// DDL skema database POSWaroeng versi 1.
///
/// Sumber tunggal definisi tabel (lihat rencana teknis §2.2). Semua perubahan
/// skema setelah rilis WAJIB lewat migrasi inkremental (lihat migrations.dart),
/// JANGAN mengubah DDL v1 yang sudah dirilis.
library;

/// Versi skema saat ini.
const int kSchemaVersion = 1;

/// Daftar seluruh statement DDL untuk membangun skema v1 dari nol.
const List<String> schemaV1 = <String>[
  // ============ MASTER ============
  '''
  CREATE TABLE categories (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    is_active     INTEGER NOT NULL DEFAULT 1
  )
  ''',
  '''
  CREATE TABLE suppliers (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    phone         TEXT,
    address       TEXT,
    is_active     INTEGER NOT NULL DEFAULT 1
  )
  ''',
  '''
  CREATE TABLE products (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    code            TEXT UNIQUE,
    name            TEXT NOT NULL,
    category_id     INTEGER REFERENCES categories(id),
    supplier_id     INTEGER REFERENCES suppliers(id),
    base_unit       TEXT NOT NULL DEFAULT 'PCS',
    stock_base      REAL NOT NULL DEFAULT 0,
    min_stock_base  REAL NOT NULL DEFAULT 0,
    cost_price_base INTEGER NOT NULL DEFAULT 0,
    sell_price_base INTEGER NOT NULL DEFAULT 0,
    is_active       INTEGER NOT NULL DEFAULT 1,
    created_at      INTEGER NOT NULL,
    updated_at      INTEGER NOT NULL,
    deleted_at      INTEGER
  )
  ''',
  'CREATE INDEX idx_products_name     ON products(name)',
  'CREATE INDEX idx_products_code     ON products(code)',
  'CREATE INDEX idx_products_category ON products(category_id)',

  // ============ MULTI SATUAN ============
  '''
  CREATE TABLE product_units (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id          INTEGER NOT NULL REFERENCES products(id),
    unit_name           TEXT NOT NULL,
    conversion_to_base  REAL NOT NULL,
    barcode             TEXT,
    cost_price          INTEGER NOT NULL DEFAULT 0,
    sell_price          INTEGER NOT NULL DEFAULT 0,
    is_base             INTEGER NOT NULL DEFAULT 0,
    sort_order          INTEGER NOT NULL DEFAULT 0,
    UNIQUE(product_id, unit_name)
  )
  ''',
  'CREATE UNIQUE INDEX idx_units_barcode ON product_units(barcode) WHERE barcode IS NOT NULL',
  'CREATE INDEX idx_units_product ON product_units(product_id)',

  // ============ PEMBELIAN / BARANG MASUK + HUTANG ============
  '''
  CREATE TABLE purchases (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    supplier_id    INTEGER REFERENCES suppliers(id),
    invoice_no     TEXT,
    purchase_date  INTEGER NOT NULL,
    total          INTEGER NOT NULL DEFAULT 0,
    paid_amount    INTEGER NOT NULL DEFAULT 0,
    status         TEXT NOT NULL DEFAULT 'LUNAS',
    due_date       INTEGER,
    note           TEXT,
    created_at     INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX idx_purchases_supplier ON purchases(supplier_id)',
  'CREATE INDEX idx_purchases_status   ON purchases(status)',
  '''
  CREATE TABLE purchase_items (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id         INTEGER NOT NULL REFERENCES purchases(id),
    product_id          INTEGER NOT NULL REFERENCES products(id),
    unit_name           TEXT NOT NULL,
    conversion_to_base  REAL NOT NULL,
    qty                 REAL NOT NULL,
    qty_base            REAL NOT NULL,
    cost_price          INTEGER NOT NULL,
    subtotal            INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX idx_purchase_items_purchase ON purchase_items(purchase_id)',
  'CREATE INDEX idx_purchase_items_product  ON purchase_items(product_id)',
  '''
  CREATE TABLE supplier_payments (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_id  INTEGER NOT NULL REFERENCES purchases(id),
    amount       INTEGER NOT NULL,
    paid_at      INTEGER NOT NULL,
    note         TEXT
  )
  ''',

  // ============ PENJUALAN ============
  '''
  CREATE TABLE sales (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_no     TEXT UNIQUE,
    sale_date      INTEGER NOT NULL,
    subtotal       INTEGER NOT NULL DEFAULT 0,
    discount       INTEGER NOT NULL DEFAULT 0,
    total          INTEGER NOT NULL DEFAULT 0,
    paid_amount    INTEGER NOT NULL DEFAULT 0,
    change_amount  INTEGER NOT NULL DEFAULT 0,
    payment_method TEXT NOT NULL DEFAULT 'TUNAI',
    note           TEXT,
    created_at     INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX idx_sales_date ON sales(sale_date)',
  '''
  CREATE TABLE sale_items (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id             INTEGER NOT NULL REFERENCES sales(id),
    product_id          INTEGER NOT NULL REFERENCES products(id),
    product_name        TEXT NOT NULL,
    unit_name           TEXT NOT NULL,
    conversion_to_base  REAL NOT NULL,
    qty                 REAL NOT NULL,
    qty_base            REAL NOT NULL,
    sell_price          INTEGER NOT NULL,
    cost_price          INTEGER NOT NULL DEFAULT 0,
    subtotal            INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX idx_sale_items_sale    ON sale_items(sale_id)',
  'CREATE INDEX idx_sale_items_product ON sale_items(product_id)',

  // ============ LEDGER MUTASI STOK ============
  '''
  CREATE TABLE stock_movements (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id   INTEGER NOT NULL REFERENCES products(id),
    qty_base     REAL NOT NULL,
    balance_base REAL,
    type         TEXT NOT NULL,
    ref_table    TEXT,
    ref_id       INTEGER,
    note         TEXT,
    created_at   INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX idx_movements_product ON stock_movements(product_id, created_at)',
  'CREATE INDEX idx_movements_ref     ON stock_movements(ref_table, ref_id)',
  '''
  CREATE TABLE stock_adjustments (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id   INTEGER NOT NULL REFERENCES products(id),
    qty_base     REAL NOT NULL,
    reason       TEXT,
    created_at   INTEGER NOT NULL
  )
  ''',

  // ============ PENGELUARAN ============
  '''
  CREATE TABLE expense_categories (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    name      TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1
  )
  ''',
  '''
  CREATE TABLE expenses (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id   INTEGER REFERENCES expense_categories(id),
    amount        INTEGER NOT NULL,
    description   TEXT,
    expense_date  INTEGER NOT NULL,
    created_at    INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX idx_expenses_date     ON expenses(expense_date)',
  'CREATE INDEX idx_expenses_category ON expenses(category_id)',

  // ============ PENGATURAN (key-value) ============
  '''
  CREATE TABLE settings (
    key   TEXT PRIMARY KEY,
    value TEXT
  )
  ''',
];
