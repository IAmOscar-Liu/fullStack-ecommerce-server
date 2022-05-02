
set session sql_mode='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


CREATE TABLE Account (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password TEXT NOT NULL,
    img_url VARCHAR(2000) DEFAULT '/images/default_user.png',
    phone VARCHAR(20),
    address VARCHAR(100),
    description TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    provider VARCHAR(30) DEFAULT 'local',
    provider_id VARCHAR(200),
    CONSTRAINT unique_name UNIQUE (name, provider)
);

CREATE TABLE Category (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    img_url TEXT NOT NULL,
    CONSTRAINT unique_category_name UNIQUE (name)
);

CREATE TABLE Product (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    img_url TEXT NOT NULL,
    description TEXT NOT NULL,
    price FLOAT(8) NOT NULL,
    isOnSale BOOLEAN DEFAULT FALSE,
    createdBy INT UNSIGNED NOT NULL,
    addedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    isAvailable BOOLEAN DEFAULT TRUE,
    CONSTRAINT unique_product_name UNIQUE (name),
    FOREIGN KEY(createdBy) REFERENCES Account(id)
);

CREATE TABLE CategoryProduct (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(category_id) REFERENCES Category(id),
    FOREIGN KEY(product_id) REFERENCES Product(id)
);

CREATE TABLE Rate (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    score INT NOT NULL,
    ratedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    CONSTRAINT unique_rate UNIQUE (product_id, account_id),
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE Post (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE Comment (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    post_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(post_id) REFERENCES Post(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE PostLike (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    post_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(post_id) REFERENCES Post(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_post_like UNIQUE (post_id, account_id)
);

CREATE TABLE CommentLike (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comment_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(comment_id) REFERENCES Comment(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_comment_like UNIQUE (comment_id, account_id)
);

CREATE TABLE Blog (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    img_url TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE BlogLike (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blog_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(blog_id) REFERENCES Blog(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_blog_like UNIQUE (blog_id, account_id)
);

CREATE TABLE BlogComment (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blog_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(blog_id) REFERENCES Blog(id),
    FOREIGN KEY(account_id) REFERENCES Account(id)
);

CREATE TABLE BlogCommentLike (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    likedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blog_comment_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(blog_comment_id) REFERENCES BlogComment(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_blog_comment_like UNIQUE (blog_comment_id, account_id)
);

CREATE TABLE MyOrder (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    session_id VARCHAR(500) NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_session_id UNIQUE (session_id)
);

CREATE TABLE OrderProduct (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL,
    payment ENUM('Incomplete', 'Succeeded', 'Failed') DEFAULT 'Incomplete',
    status ENUM('Pending', 'Cancel', 'In Progress', 'Delivered', 'Return') DEFAULT 'Pending',
    product_id INT UNSIGNED NOT NULL,
    order_id INT UNSIGNED NOT NULL,
    orderedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updateAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(order_id) REFERENCES MyOrder(id)
);

CREATE TABLE Favorite (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    addedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(product_id) REFERENCES Product(id),
    FOREIGN KEY(account_id) REFERENCES Account(id),
    CONSTRAINT unique_favorite UNIQUE (product_id, account_id)
);

INSERT INTO
    Account(name, email, password)
VALUES
    (
        "Oscar",
        "karta0989006@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "David",
        "david@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "John",
        "john@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "Kevin",
        "kevin@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "Tony",
        "tony@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "Allen",
        "allen@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "Anna",
        "anna@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "Elsa",
        "elsa@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "Olaf",
        "olaf@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    ),
    (
        "Tiffany",
        "tiffany@gmail.com",
        "$2a$12$wHD6o5AvdcC9SpHazvHSz.CJ/RI3.IWtPbUq.5lF2GNXhXUE1ihGa"
    );

INSERT INTO
    Category(name, img_url)
VALUES
    (
        "electronics",
        "/images/categories/electronics.jpg"
    ),
    (
        "cell phones & accessories",
        "/images/categories/cell_phone_and_accessories.jpg"
    ),
    (
        "clothing, shoes & jewelry",
        "/images/categories/clothing_shoes_and_jewelry.jpg"
    ),
    (
        "home & kitchen",
        "/images/categories/home_and_kitchen.jpg"
    ),
    (
        "grocery & gourmet food",
        "/images/categories/grocery_and_gourmet_food.jpg"
    ),
    (
        "sport & outdoors",
        "/images/categories/sport_and_outdoors.jpg"
    ),
    (
        "toys & games",
        "/images/categories/toys_and_games.jpg"
    ),
    (
        "beauty & personal care",
        "/images/categories/beauty_and_personal_care.jpg"
    ),
    (
        "office products",
        "/images/categories/office_products.jpg"
    ),
    ("others", "/images/categories/others.jpg");

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "displayAcer TravelMate P6 Thin & Light Business Laptop",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_1%2Fproduct_001.jpg?alt=media&token=46853d7c-2842-4355-9663-1701863003ee",
        "10th Generation Intel Core i5-10310U with vPro Processor (Up to 4.4GHz) | 8GB DDR4 Memory | 256GB NVMe SSD<br/>14.0 Full HD (1920 x 1080) Widescreen LED-backlit IPS Display | Intel UHD Graphics<br/>Intel Wireless Wi-Fi 6 AX201 802 11ax | Backlit Keyboard | Fingerprint Reader | Bluetooth 5.0<br/>1 - Thunderbolt 3 (Full USB 3.1 Type C) Port | 2 - USB 3.1 Gen 1 Ports (one featuring power-off USB charging) | 1 - HDMI 2.0 Port with HDCP support<br/>Windows 10 Professional | Military Grade Tough | TPM 2.0 |Lightweight: Only 2.57 lbs | Up to 23 Hours Battery Life | Power up to 100% capacity in just two hours with Fast Charging",
        786.16,
        1,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 1),
    (9, 1);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Samsung Tab A7 Lite 8.7 Gray 32GB",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_2%2Fproduct_002.jpg?alt=media&token=f03f83fc-fc61-41d9-b0c9-bcd595f5093d",
        "THE ENTERTAINMENT GOES WHERE YOU GO: With its compact 8.7” screen, slim design and sturdy metal frame, Galaxy Tab A7 Lite is perfectly sized for entertainment on the go<br/>STURDY FRAME FOR LASTING PROTECTION: Galaxy Tab A7 Lite features an upgraded metal frame that helps protect against everyday hiccups<br/>TWO MONTHS OF AD-FREE VIDEO FUN: Keep everyone in the family entertained with two months of free YouTube Premium¹ for hours and hours of ad-free fun<br/>PERFORMANCE THAT WON'T LET YOU DOWN: Comes with fast speed and plenty of storage for multiple users",
        119.33,
        2,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 2),
    (2, 2),
    (7, 2);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Fitbit Versa 2 Health and Fitness Smartwatch",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_3%2Fproduct_003.jpg?alt=media&token=79f6b051-d458-4f39-90d5-97a6ec855499",
        "Use amazon Alexa built in to get quick news and information, check the weather, set timers and alarms, control your smart home devices and more all through the sound of your voice (third party app may be required; amazon Alexa not available in all countries<br/>Based on your heart rate, time asleep and restlessness, sleep score helps you better understand your sleep quality each night; also track your time in light, deep and REM sleep stages and get personal insights<br/>Control your Spotify app, download Pandora stations and add Deezer playlists (subscription required; Pandora is US only)<br/>With a larger display and an always on option, your information’s always a quick glance away (always on display requires more frequent charging)<br/>Track heart rate 24x7, steps, distance, calories burned, hourly activity, active minutes and floors climbed. Syncing range - up to 6.1 meters<br/>Works around the clock with 6 plus day battery life (varies with use and other factors)<br/>Get a call, text, calendar and smartphone app notifications when your phone is nearby; plus send quick replies and a voice replies on android only. Works with Bluetooth headphones & 200 plus leading iOS and Android devices.",
        116.95,
        3,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 3),
    (2, 3),
    (6, 3),
    (7, 3);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "UMETRAVEL True Wireless Earbuds",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_4%2Fproduct_004.jpg?alt=media&token=31bb86c6-3ec3-43bc-babe-e02363e0bd66",
        "Pure Treble & Powerful Bass: From the highest treble to deepest bass, PEK & PU Dual Diaphragm produces pure, incredibly clear sound. One-step pairing you will be in euphonic music world in a couple of seconds.<br/>Hollow Metallic Charging Case: The 18mm ultra-thin body is made of premium lightweight of aluminlum alloy, and the hollow design charging compartment makes this more recognizable.<br/>Low Audio Latency: True wireless earbuds create a seamless & ultimate gaming experience which feel the thrill in action.<br/>Clear Calls: Better hear your voice, while rejecting most of the noise around you. No matter where you are, stay connected.<br/>24H+ PlayTime: The earbuds giving 24 hours of total playtime. Testing conducted by iPhone XR volume was set up to 80%. Battery life may vary on device settings, volume, environment, usage, and many other factors.",
        59.99,
        4,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 4),
    (2, 4);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Epson Workforce ES-400",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_5%2Fproduct_005.jpg?alt=media&token=c28813fe-47a7-42fc-8035-58c4ba22b215",
        "Get organized in a snap — scan up to 35 ppm/70 ipm (1); Single-Step Technology captures both sides in one pass<br/>Quickly scan stacks of paper — robust 50-sheet Auto Document Feeder easily accommodates multiple paper types and sizes in one batch<br/>Powerful software included — easy scanning with intuitive Epson ScanSmart Software (2); preview, email, upload to the cloud and more; automatic file naming saves time<br/>Seamless integration with most software solutions — the included TWAIN driver allows you to easily incorporate your data into most document management software<br/>Easy sharing and collaboration — email or upload to popular cloud storage services (2) such as Dropbox, Evernote, Google Drive and OneDrive<br/>Simplified file management — create searchable PDFs with included Optical Character Recognition (OCR); convert scanned documents to editable Word and Excel files<br/>Intelligent color and image adjustments — auto crop, blank page skip, background removal, dirt detection and paper-skew correction with Epson Image Processing Technology",
        292.98,
        5,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 5),
    (9, 5);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Brother Compact Monochrome Laser Printer",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_6%2Fproduct_006.jpg?alt=media&token=d5f8380b-db35-4dcd-8dfc-4c6a234a82fa",
        "Print more, wait less. Engineered for increased efficiency with class leading print speeds of up to 32 pages per minute.<br/>Dynamic features accommodate your evolving needs. The 250-sheet paper capacity helps improve efficiency with less refills and handles letter or legal sized paper.<br/>Flexible printing. The manual feed slot offers flexible paper handling for a variety of papers and sizes, such as card stock, envelopes, etc. to help you create professional looking documents.<br/>Printing as mobile as you are. Print wirelessly from your desktop, laptop, smartphone and tablet.<br/>Connect your way. Versatile connection options with built-in wireless or connect locally to a single computer via its USB interface.",
        209.50,
        6,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 6),
    (9, 6);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Intel Core i5-10400 Desktop Processor",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_7%2Fproduct_007.jpg?alt=media&token=39778b37-4c11-4916-ba5e-0867818e9da7",
        "6 Cores / 12 Threads<br/>Socket type LGA 1200<br/>Up to 4. 3 GHz<br/>Compatible with Intel 400 series chipset based motherboards<br/>Intel Optane Memory support<br/>Cooler included",
        153.50,
        7,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 7),
    (2, 7),
    (9, 7);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "PRITOM 10 inch Tablet",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_8%2Fproduct_008.jpg?alt=media&token=17d68ea2-05f2-4339-9bbb-1c3c82bdd780",
        "Remarkable Android 10.0 tablet: Features a robust Octa-core Processor 1.6 GHz and 3GB RAM.Together with Android 10.0 , L10 tablet delivers quick app launches, smooth games and videos, not only faster boot, standby more energy saving, so that the efficiency of office learning is guaranteed. Tablet L10 includes a micro SD card slot ( can be added an extra TF/SD card, NOT included), making it more convenient to store more fires, songs, pictures, videos, and download more games<br/>Powerful &Slim: The 8mm narrow bezel and 2.5D touch panel and metal body bring comfortable hand feeling.This Android tablet is assembled from an aluminum alloy case.The metallic finish and slim design make it easy to use around the house or on the go.And the G G glass screen will look better and will not be easily scratched. With 8MM ultra-thin design,larger viewing area, bringing you incomparably pure visual effects.You can enjoy fun anytime, anywhere<br/>Enjoy a Visual Feast: Features 1280*800 brilliant HD IPS display and box speakers. With 1280x800 HD IPS display, L10 presents crisp, clear details and vivid colors for a more true-to-life viewing experience from all angles.The Eye Health mode automatically adjusts and optimizes the backlight for a more comfortable nighttime reading experience;Pritom L10 tablet equipped with dual BOX speakers, Big size speaker with large volume enhances your experience, whether you are working or getting entertai<br/>Entertainment no limits: Its large-capacity 6000mAh battery can effortlessly support you for up to 10 hours of reading, browsing, watching movies and playing games.32 hours of music playback.15W fast charge can be fully charged in 2.8 hours.Premium battery performance and lightweight metal design make it possible for you to take anywhere, anytime.<br/>Large and Expandable Storage: 32GB of onboard memory and a microSD card slot can expand your storage to up to 128GB, that allows you to add up to an additional 128GB of memory, keep all your favorite media with you wherever you go, such as eBooks, songs, videos, photos, music, etc.",
        119.95,
        8,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 8),
    (7, 8),
    (9, 8);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Western Digital 4TB WD Red Plus NAS Internal Hard Drive",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_9%2Fproduct_009.jpg?alt=media&token=1cc39a7c-156d-44ed-8b68-bfed7b363ec1",
        "Available in capacities ranging from 1-14TB with support for up to 8 bays<br/>Supports up to 180 TB/yr workload rate Workload Rate is defined as the amount of user data transferred to or from the hard drive. Workload Rate is annualized (TB transferred ✕ (8760 / recorded power-on hours)). Workload Rate will vary depending on your hardware and software components and configurations.<br/>NASware firmware for compatibility<br/>Small or medium business NAS systems in a 24x7 environment",
        84.99,
        9,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 9),
    (10, 9);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Dell DA310 USB-C Mobile Adapter",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_10%2Fproduct_010.jpg?alt=media&token=9bd43fe1-d145-49d6-9c33-6eab87758757",
        "Featuring the widest variety of ports available, the compact 7-in-1 Dell USB-C Mobile Adapter – DA310 offers video, network, data connectivity, and up to 90W power pass-through for your laptop.<br/>Product Type: Docking station. Docking Interface: USB-C.<br/>Video Interfaces: VGA, HDMI, DP, USB-C.<br/>Dimensions (WxDxH): 2.7 in x 2.7 in x 1 in. Weight: 2.82 oz.<br/>The DA310 supports max 90W power delivery passthrough.",
        119.99,
        10,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 10),
    (2, 10),
    (10, 10);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "JBL Clip 3 Portable Bluetooth Speaker",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_11%2Fproduct_11.jpg?alt=media&token=529ab501-eb20-487f-80f1-036e6fca6d39",
        "SOUND TO GO - Never leave awesome sound at home again. This ultra-portable, waterproof Bluetooth speaker is small in size but with surprisingly big sound. Clip it on with the built-in carabiner, press play, and make the moment pop.<br/>UP TO 10 HOURS OF PLAYTIME - The JBL Clip 3 features a built-in rechargeable Li-ion battery with up to 10 hours of battery life, plus a metal carabiner so you can easily hook it to your clothes, backpack, or belt loop.<br/>NOISE CANCELLING & WIRELESS STREAMING - Wirelessly stream high-quality sound from your smartphone or tablet. Plus, take crystal-clear calls from your speaker with the touch of a button, thanks to the noise and echo-cancelling speakerphone.<br/>WATERPROOF & DURABLE - No more worrying about rain or spills: JBL Clip 3 is completely waterproof—you can even immerse it in water. Plus, the improved, durable fabric material and rugged rubber housing protects it on all of your outdoor adventures.<br/>THE SOUND PROMISE - JBL has brought music to life in a way people can feel for over 70 years. From Woodstock to the Motion Picture Academy, our speakers unleash the power of music so you can live life to the fullest, wherever and whenever.",
        44.96,
        1,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 11),
    (2, 11),
    (6, 11),
    (7, 11);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Logitech K380 Multi-Device Bluetooth Keyboard",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_12%2Fproduct_12.jpg?alt=media&token=f5a3133f-2241-4a17-9353-bf48200bfef4",
        "Multi-device Bluetooth keyboard: Universal keyboard for typing on all your computing devices: Windows, Mac, Chrome OS, Android, iPad, iPhone, Apple TV 2nd or 3rd generation (Any Bluetooth-enabled computers or mobile devices that support external keyboards with HID profile. Check with device manufacturer for details.)<br/>Easy-switch: Connect up to 3 devices simultaneously and switch between them at the touch of button. Wireless range 10 meter<br/>Logitech flow cross-computer typing: Use as a regular keyboard or combine with a compatible Logitech flow mouse (sold separately) to type, copy, paste and move files seamlessly between computers<br/>Compact mobile keyboard: Easy to carry around your home for familiar typing in any room and Logitech options for Windows (Windows 7, Windows 8, Windows 10 or later), Logitech options for Mac (OS X 10.8 or later)<br/>OS adaptive: Automatically recognizes each device and maps keys to give you a familiar layout, including shortcuts. Battery life (not rechargeable) - 24 months. Connection type: Bluetooth classic (3.0)<br/>2 year battery life: Virtually eliminates the need to change batteries (Keyboard battery life calculation based on an estimated 2 million keystrokes/year in an office environment. User experience may vary.)<br/>1 Year Limited Hardware Warranty",
        49.96,
        2,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 12),
    (2, 12),
    (9, 12),
    (10, 12);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Coiled Lightning Cable",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_13%2Fproduct_13.jpg?alt=media&token=5df75c5a-9f22-4925-8c59-9294dd13b2ff",
        "【3ft or 6ft?】3ft is optimized for CarPlay,. If you prefer using CarPlay and storing your iPhone away in the compartment without any movement, we recommend 3ft. 6ft is optimized for Charging & CarPlay. Stretchy and flexible. Can easily be extended to the dash mount, air vent mount, and even the backseat. If you prefer flexible usage, we recommend 6ft (5% who chose 3ft thought it too short)<br/>【CarPlay Compatible & MFi Certified】Fully support CarPlay. Our officially MFi certified coiled lightning cable can secure a reliable & firm connection. Get directions, answer calls, reply to messages all with this cable<br/>【0 to 40% in 30mins】Fast charging for your iPhone 13/iPhone 12, 0 to 40% in 30mins or 75% in 1hr. Best for pairing with portable power banks while on a trip. We also recommend pairing with dé 38W USB Car Charger for maximum charging speed<br/>【Coiled = Less Cord & Less Mess】de Coiled iPhone Cable, iPhone car charger cable (USB to Lightning Cable), a perfect short cable solution. Remove all the clutter and excess cabling of long cords, tuck away your iPhone in the compartment while not using it. Easy to store away, expands to the length when needed. No more silly long wires, no twisted cables<br/>【Wide Compatibility】Compatible with all iPhone models, iPhone 12 Pro Max, iPhone 12 Pro, iPhone 12, and iPhone 12 mini, iPhone 13, 11, Xs, Xr, X, SE, and iPhone 8/7/6/5. Compatible with other lightning devices like iPad, AirPods",
        14.96,
        3,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 13),
    (2, 13),
    (10, 13);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Cellphone Supporter",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_14%2Fproduct_014.jpg?alt=media&token=02ac7c0c-f0a8-4af1-8a58-23e699046e2c",
        "【Upgraded Gooseneck Phone Holder】Lamicall upgraded gooseneck long phone holder uses longer leather-wrapped arm(98cm), more flexible 360 Adjustable & Rotatable ball joint phone clamp design and a reinforced base, which gives it a better texture, stability and flexibility. A perfect flexible phone holder that can free your hands to watch movies, make Facetime calls or record videos, etc.<br/>【Wide Compatibility】This lazy bracket iphone holder suits for all 4-7'' devices, almost all smartphones, like iPhone 13 12 Mini, 12, 12 Pro, 12 Pro Max, 11 Pro, 11, 11 Pro Max, SE 2020, XS, XS Max, XR, X, 8 7 6 Plus, Switch, Galaxy S21 Ultra, S20, S10, S9, S9 Plus, A71, A51, A11, Edge, Note 20 ultra Google Pixel,LG, LG,Nexus, HTC, Google Pixel, Huawei Mate Pro, Xiaomi Redmi etc.<br/>【Longer Arm, Sturdy Yet Flexible】Using Double layer durable material: 38.6inches (98cm) flex leather-wrapped arm and high-quality aluminum alloy solid core. This overhead phone mount stand has a more reachable range and sturdy enough to hold your phone firmly, yet flexible to shaped to accommodate your view. No bow your head. No more neck pain. Note: Recommend to bend into  S  or  Z  for adding more stability.<br/>【Easier Angle Adjustment】Thanks to the user-friendly design of the 360-degree ball swivel joint between the arm and phone clamp, you can make some small angle adjustments easily without having to bend the entire snake neck every time to achieve the same purpose.<br/>【Excellent Versatility】Featuring a screw-on clamp base varying from 0 to 2.7 inches (7cm), the bendy cell phone clip holder can be securely mounted on the edge of the bed frame, bedside, headboard, nightstand, desk, end table, chair and kitchen counter, etc.",
        27.99,
        4,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 14),
    (2, 14),
    (10, 14);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Coiled Lightning CableVINABTY BN59-01199F Replaced Remote",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_14%2Fproduct_014.jpg?alt=media&token=02ac7c0c-f0a8-4af1-8a58-23e699046e2c",
        "new replaced remote. No need to set up.<br/>ust need put new battery to use.<br/>The remote fit for samsung tv models: UN32J4500AF / UN32J4500AFXZA / UN32J5205AF / UN32J5205AFXZA / UN32J525DAF / UN32J525DAF / UN32J525DAFXZA / UN32J525DAFXZA / UN40J5200AF / UN40J5200AFXZA / UN40J520DAF / UN40J520DAF / UN40J520DAFXZA / UN40J520DAFXZA / UN40J6200AF / UN40J6200AFXZA / 6200 series UN40JU6700 UN48JU6700 UN55JU6700 UN65JU6700 6520 series UN32J5205 7500 9500<br/>UN40JU6400F / UN40JU6400FXZA / UN40JU640DAFXZA / UN40JU640DFXZA / UN40JU650DF / UN43J5200AF / UN43J5200AFXZA / UN43J520DAF / UN43J520DAF / UN43J520DAFXZA / UN43J520DAFXZA / UN43JU640DF / UN43JU640DFXZA / UN48J5200AF / UN48J5200AFXZA / UN48J5201AF / UN48J5201AFXZA /<br/>UN60J6200AFXZA / UN60J620DAF / UN60J620DAF / UN60J620DAFXZA / UN60J620DAFXZA / UN60JU6400F / UN60JU6400FXZA / UN65J6200AF / UN65J6200AFXZA / UN65J620DAF / UN65J620DAF / UN65J620DAFXZA / UN65J620DAFXZA / UN65JU6400F / UN65JU6400FXZA / UN65JU640DAFXZA / UN65JU640DF / UN65JU640DFXZA, etc.",
        6.85,
        5,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (1, 15),
    (2, 15),
    (4, 15),
    (9, 15),
    (10, 15);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "GLORIA VANDERBILT Women's Classic Amanda High Rise Tapered Jean",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_16%2Fproduct_016.jpg?alt=media&token=8ddf882d-c1c1-4989-98d4-91e30ca2b304",
        "100% Cotton<br/>Gloria Vanderbilt branded button and rivets. Classic 5 pocket design denim pant. Front YKK zip and button closure. Sits at natural waist.<br/>Classic-rise jeans pant for women. 5 belt loops to accommodate up to a 2 inch belt. Sculpt stretch ensures maximum recovery. Ultra-stretch fabric and Tapered leg<brr>Available in Standard and Plus Sizes. Sizing II Standard sizes: 4-18 Average- Inseam (in): 31 and Plus sizes: 16W-22W Average - Inseam (in): 30 ½. Colors: Black, Black Stencils, Scottsdale Blue, Celestial Blue, Rinse Nior Blue and Dark Rust<br/>Colors: Black, Beige, Green, Dark Blue, Silver, White, Frisco, Hartford, Rinse Noir, Rusty, Hazelnut, Chicago, Alton Whiskers, Madison, Black Stencils, Coffee roast, Seattle, Grey opal.<br/>All sizes are standard but may vary from different brands. Color names are approximately defined here within the scope of arbitrary judgement. Color of actual product may slightly be different than shown on your computer due to different resolutions.",
        9.01,
        6,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 16),
    (4, 16);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Playtex Women's Confert Strap Full Coverage Bra",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_17%2Fproduct_017.jpg?alt=media&token=2b9063f1-4ad9-46fc-8b47-c19f745e2d71",
        "100% Polyester<br/>Imported<br/>Soft lining<br/>Hook and Eye closure<br/>Machine Wash<br/>​Comfort You Deserve. No slip, back adjustable, comfort cushion straps to help relieve pressure on the shoulders and prevent dig-in. Wireless Comfort. No itchy tags, we are all tagless<br/>Support You Can Trust. Fuller cups with supportive M-frame for amazing support. TruSupport bra design that provides a 4-way support system: extra side and extra back support, fuller cups to reduce spillage, and designed with Comfort strap(R) for all-day comfort. Exclusive Spanette fabric stretches four ways for all day support.",
        16.99,
        7,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 17),
    (8, 17);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Playtex Women's Active Lifestyle Full Coverage Bra",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_18%2Fproduct_18.jpg?alt=media&token=1df9988f-a9d8-4b1e-9e9c-791a5fbbdb78",
        "polyester|nylon|spandex|cotton<br/>Seamless lining<br/>Hook and Eye closure<br/>Comfort You Deserve. Wicking, cool comfort cups to help keep you cool. Breathable fabric for all day comfort and all around cooling. Inner cooling comfort band. Comfort Cushion Straps are designed to help take the stress off of your shoulders. Wireless Comfort. No itchy tags, we are all tagless.<br/>Support You Can Trust. 4-way TruSupport bra design that provides a 4-way support system: higher sides and a taller back for extra side and back support, fuller cups and our wide comfort strap for all-day comfort.<br/>Your Perfect Fit. Designed with a no ride up back.",
        12.00,
        8,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 18),
    (8, 18);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Hanes Women's ComfortFlex Fit Wirefree Bra",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_20%2Fproduct_20.jpg?alt=media&token=989394a6-fa59-4fa0-8e34-a1635437f44d",
        "Cup: 84% Nylon, 16% Spandex; Lace: 79% Nylon, 21% Spandex<br/>Imported<br/>Hand Wash Only<br/>Feather-lite fabric for second skin comfort<br/>Comfort band provides stay in place support<br/>Flexible foam cups provide shape and support<br/>Sleek styling virtually invisible under clothes",
        7.99,
        9,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 19),
    (8, 19);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Neezeelee Dress Pants for Women",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_20%2Fproduct_20.jpg?alt=media&token=989394a6-fa59-4fa0-8e34-a1635437f44d",
        "62.8% Viscose, 32.3% Polyester, 4.9% Spandex<br/>Made in USA or Imported<br/>Pull On closure<br/>Machine Wash<br/>Flattering Skinny Fit: 4-Way Stretch Knit makes these stretchy pants fit like a dream. Modern Leg, High-rise, Fitted through the hip and thigh. Making them a quick and comfortable option for starting any outfit with style<br/>Classic Comfort: Pull-on style, (No zipper, no closure). They pull on like leggings, Elasticized waistband that moves with you, and smooths out any imperfections. Now you can look office-ready while enjoying all the comfort of your favorite yoga pants.<br/>Added Features: Elastic and durable waist elastic with front pockets, Comfortable Fit with Skinny leg pants for touch of chic. Higher rise designed to keep them from slipping down when bending or crouching. Added back yoke seam for a better fit- No gaping!",
        34.99,
        10,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 20),
    (4, 20),
    (8, 20);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Cotton High Waisted Soft Womens Underwear Breathable Panties 2",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_21%2Fproduct_021.jpg?alt=media&token=ac9485ae-a975-4f32-91e9-c5d5c6765acb",
        "95% cotton and 5% spandex, the extended crotch is 100% cotton<br/>Imported<br/>Machine Wash<br/>COTTON BREATHABLE MATERIAL: This women’s underwear are made of 95% high quality combed cotton and 5% spandex. The crotch of this women’s panties is extended double layer 100% cotton, they are soft, comfortable and breathable.<br/>SHOW PERFECT BODY SHAPE: This ladies high-waisted panties with high stretchy and very close, they could cover your muffin-top and cover your hips, perfectly show your body shape<br/>NO FADING AND DISTORTION: This womens cotton briefs are used activated health dyeing technology, processed and washing tested in a variety of complicated, these women underpants are not easy to fade, skin-friendly, not pilling and deform. Moreover, the high-quality cotton underwear are not roll or gather and compress, it allows you to be free and active all day.<br/>WIDE RANGE OF USES: This women's high rise underpants fit for matching slim jeans, skirts, shorts and wedding dresses. Furthermore, you can rest assured that they are not show panty lines. These super comfort panties are a perfect choice for postpartum c-section recovery and abdominal surgery recovery. They stay above the scar and won’t irritate incision. Also helping tummy control and recovering a firm skin.<br/>AFTER-SALES GUARANTEE: Making you 100% satisfied is our top priority! If you are not satisfied with our products for any reason, please contact us and we will timely provide high quality solutions and services for you. Please carefully check the size chart before purchasing.",
        24.99,
        1,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 21),
    (8, 21);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Cotton High Waisted Soft Womens Underwear Breathable Panties",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_22%2Fproduct_022.jpg?alt=media&token=7215d42a-e80d-434e-9ec6-a036d42042e0",
        "Polyester,Spandex,Rayon<br/>Button closure<br/>Hand Wash Only<br/>Material:60% Polyester,35% Rayon,5% Spandex.Skin Friendly fabric,Soft and Comfortable<br/>Unique Design:Long Sleeve Casual Tunic Shirt,This asymmetrical hem tunic is incredibly soft and comfortable! It classy and fun.The buttons on the side are non-functioning, but attractive.<br/>Match:It's Easy to Pair with Jeans,Leggings,Shorts,Pants and High Boots,Perfect to Wear with a Pretty Necklace for a Fashion Look,Which Makes You Looks More Stylish and Elegant.<br/>Ocassion: Suitable for Casual Daily/ Travel/ Home/ Vacation/ Shopping/ Street/ Party/ Outdoor/ Club to Wear.The Best Gifts for Women.<br/>Wash Care: Machine Washable In Gentle, Recommend Hand Wash In Cold Water, Line Dry, Do Not Bleach.",
        16.99,
        2,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 22),
    (8, 22);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Afibi Womens High Waisted Skirts with Pocket",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_23%2Fproduct_023.jpg?alt=media&token=9f10f056-88f2-4887-8e11-00c449235a7d",
        "100% Polyester<br/>Button closure<br/>Material:100 % Polyester.Soft fabric and comfortable touch, not easily deformed.<br/>Causal Pleated Midi Skirt With Two Pocket on Side,Button Front as a decoration, Back Elastic Waistband, Unlined.<br/>Classical A-Line Solid Color Single Breasted Skirt knee length Shows elegant and intellectuality.<br/>It is easy to match, just pair with your favorite top,t shirt or blouse for an effortless style.Perfect for spring summer fall winter, such as office, school, shopping, party, dating, vacation etc.<br/>Model Body Size: Height: 5'8, Waist: 25 inches, Hip: 35 inches, model is wearing a Small",
        22.99,
        3,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 23),
    (8, 23);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "LifeStride Women's Suki Pump",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_24%2Fproduct_024.jpg?alt=media&token=01d9c89c-a603-44b4-8145-5e3effdfad94",
        "100% Synthetic<br/>Imported<br/>Synthetic sole<br/>Heel measures approximately 2.76<br/>Available in Medium and Wide Widths<br/>Size :UK 3 US 5M EUR 35",
        42.33,
        4,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 24),
    (8, 24);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Skechers Women's Go Walk Joy Walking Shoe",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_25%2Fproduct_025.jpg?alt=media&token=3343db12-682f-42ef-84f5-b6fd76b51e5a",
        "Textile<br/>Imported<br/>Synthetic sole
<br/>Shaft measures approximately low-top from arch<br/>Lightweight and flexible<br/>Responsive 5Gen cushioning<br/>Skechers Goga Max high rebound insole",
        32.99,
        5,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 25),
    (8, 25);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "HC Collection King Size Sheets Set",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_26%2Fproduct_026.jpg?alt=media&token=7c0409ab-a9dc-4882-9da8-0a0b3bb0ba64",
        "Complete Set: Our pillow case and bed sheets set has everything you need - (2) 20x40 pillowcases, (1) 102x105 flat sheet, and (1)78x80 fitted sheet with deep pockets that fit up to 16 inches.<br/>Super Soft: This 1800 thread count microfiber king size bed sheet set will make you feel like you're laying in the lap of luxury.<br/>Breathable: This bedding set is built for year-round relaxation! They're moisture-resistant, designed to keep you warm in the winter, and act as cooling bed sheets in the summer.<br/>Fade Resistant: Not only does our bedding come in multiple colors, they won't fade on you after multiple washes.<br/>Easy Cleaning: Losing sleep over complicated washing instructions? Well, our deep pocket sheets and pillowcases are totally machine washable to give you peace of mind!",
        32.99,
        6,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 26),
    (8, 26),
    (10, 26);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "PharMeDoc Pregnancy Pillow",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_27%2Fproduct_027.jpg?alt=media&token=74798a51-aebd-4db1-8a98-97c76b264c40",
        "Our new U-Shape Pillow now comes with a special Cooling cover that is cool to the touch and helps disperse heat. Perfect for the summer or during pregnancy to help you feel cooler through the night.<br/>The pregnancy pillow features a detachable extension that can be used as its own full body pillow, or attached the main body pillow for additional back or belly support, making this an excellent pillow for pregnant women and just about anyone else!<br/>This maternity pillow measures 53 inches long, 31 inches wide, and 7 inches high, making this the ideal contoured support pillow for your back, belly, legs, and neck... all in one!<br/>MORE THAN JUST A PILLOW FOR PREGNANT WOMEN - This full body pillow is perfect for ANYONE needing more support, recovering from surgery, or tired of having to use separate pillows to support their head, neck, legs, and back<br/>Try the PharMeDoc U-Shaped maternity pillow today, RISK-FREE. You're covered by our lifetime manufacturer warranty and 100% satisfaction guarantee.",
        42.95,
        7,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 27),
    (8, 27),
    (10, 27);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Snuggle-Pedic Full Body Pillow for Adults",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_28%2Fproduct_028.jpg?alt=media&token=4181b640-3024-4d2e-8be2-64408a172d66",
        "Soft Memory Foam - Our body pillows for sleeping use shredded foam to keep you supported, no matter what side you sleep on. It conforms to your body shape, promoting alignment for your legs, back, and hips.<br/>GreenGuard Gold Certified - Rest easy knowing this full body pillow is put under strict third-party lab testing and is GreenGuard Gold and Certi-PUR US certified to ensure safety, quality, and comfortability.<br/>Chiropractor Designed - Sleep tight and melt the stress away with a big pillow that's been developed by a chiropractor for pain-free nights.<br/>Kool-Flow Tech - This cooling body pillow isn't all talk! The fabric on its luxurious, extra-breathable cover will keep you cool on even the hottest nights.<br/>USA Made - Get the support you need, without the guilt. Our long pillows for sleeping are super durable, built for everyone, and best of all, made in the USA!",
        59.99,
        8,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 28),
    (8, 28),
    (10, 28);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Kraus Standard PRO Steel Kitchen Sink",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_28%2Fproduct_028.jpg?alt=media&token=4181b640-3024-4d2e-8be2-64408a172d66",
        "INDESTRUCTIBLE CONSTRUCTION: Dent-resistant T304 stainless steel in TRU16 real 16-gauge (always 1.5mm thick) for superior strength and durability<br/>COMMERCIAL GRADE SATIN FINISH: Resilient and easy to clean, corrosion and rust-resistant; matches most kitchen appliances<br/>QUIETEST SINK: NoiseDefend soundproofing technology with non-toxic SoundGuard undercoating and extra-thick pads covering over 80% of the sink<br/>Outer Sink Dimensions: 32 3 4” L x 19” W x 10” D. Min Cabinet Size: 36”; Versatile oversized double bowl sink perfect for multi-tasking, soaking and washing your largest pots and pans",
        395.95,
        9,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 29),
    (10, 29);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Stone & Beam Lauren Down-Filled Oversized Sofa Couch",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_30%2Fproduct_30.jpg?alt=media&token=6fc7a9bc-9254-4e32-bf63-abcee3158629",
        "Get comfort you can literally sink into with this contemporary overstuffed sofa. A clean and simple silhouette with track arms in a durable performance fabric, it's the perfect addition for your living room.<br/>Dimensions: 89.4''W x 44.9”D x 37.4”H; seat height 18.5, seat depth 25<br/>Solid hardwood frame with moisture repellent, stain resistant fabric and down-filled cushions<br/>Removable and reversible seat cushion.<br/>No assembly required<br/>Avoid moisture. Wipe with a soft, dry cloth.<br/>Free returns for 30 days. 3-year warranty.",
        695.95,
        10,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 30),
    (10, 30);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Pringles Potato Crisps Chips",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_31%2Fproduct_031.jpg?alt=media&token=5bfca14d-5eae-4fb8-ba9e-0a731003713d",
        "Satisfy your snack craving with the irresistible taste of original flavor, cheddar cheese flavor, sour cream and onion flavor, bbq flavor, pizza flavor, and cheddar and sour cream flavor potato crisps<br/>Make snack time more fun with the original, stackable potato crisp; pop open a can and experience the bold flavor and satisfying crunch of Pringles Potato Crisps<br/>Always tasty, never greasy; a delicious and crispy way to put the wow in your snacking routine; a travel-ready food made to enjoy at home or on-the-go<br/>Grab a cup at game time, pack a snack for school, enjoy a stack at the office and stow them in lunchboxes; the savory, stackable snack options are endless<br/>19.5-oz box containing 6, 0.67-oz cups of Original, 6, 0.74-oz cups of Sour Cream & Onion, 6, 0.74-oz cups Cheddar Cheese, 3, 0.74-oz cups BBQ, 3, 0.74-oz cups Pizza, and 3, 0.74-oz cups of Cheddar & Sour Cream Flavored Pringles Potato Crisps",
        14.58,
        1,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (5, 31),
    (10, 31);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Welch's Fruit Snacks",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_32%2Fproduct_032.jpg?alt=media&token=3c933dc6-703c-4fc3-a927-7f96c50e0f08",
        "Includes (40) 0.9 oz single serving bags<br/>Delicious fruit snacks where fruit is the 1st Ingredient<br/>100% Vitamin C, 25% Vitamins A&E (DV per serving)<br/>Gluten free, fat free & preservative free<br/>Perfect tasty snack for school lunches, sporting games, the office and more",
        8.57,
        2,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (5, 32),
    (10, 32);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "PLANTERS Deluxe Mixed Nuts with Hazelnuts",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_33%2Fproduct_033.jpg?alt=media&token=dc0bcd0a-e91a-4f8d-84fb-b9bff95dc994",
        "FORMULA CHANGE: We have changed our Mixed Nuts formula to include Brazil nuts instead of Hazelnuts; For a short time, you may receive Mixed Nuts with Hazelnuts or Mixed Nuts with Brazil Nuts while we are transitioning inventory.<br/>DELUXE MIXED NUTS: PLANTERS Deluxe Mixed Nuts With Hazelnuts delivers delicious hearty taste Snack on a crunchy mix of PLANTERS nuts—cashews, almonds, hazelnuts, pistachios and pecans<br/>PLANTERS NUTS: This 15.25 ounce resealable canister of PLANTERS Deluxe Mixed Nuts With Hazelnuts contains about fifteen 1 ounce servings and features a resealable lid designed to lock in long-lasting freshness<br/>SALTED MIXED NUTS: Mixed nuts are seasoned with sea salt for an enhanced taste<br/>ROASTED MIXED NUTS: These mixed nuts are roasted in peanut oil for satisfying flavor and crunchy texture<br/>SNACKS: Mixed nuts contain 160 calories per 1 ounce serving—they're energizing and delicious<br/>KOSHER CERTIFIED MIXED NUTS: PLANTERS mixed nuts are great tasting nutrient dense snacks for those keeping Kosher",
        9.49,
        3,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (5, 33),
    (10, 33);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Siffler Shopping Cart with 360° Rolling Swivel Wheels",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_34%2Fproduct_034.jpg?alt=media&token=9d31210d-aa33-42d3-b183-db0c07d71289",
        "360°Swivel Front Wheels: For Optimal Maneuverability, make you roll this go-to shopping cart more easily during turning around or changing direction in the bumpy sidewalk. You can change directions smoothly for quick & easy use.<br/>Room Saving Grocery Cart: This foldable shopping cart is especially for the elderly, people who have back troubles, women that are pregnant, and so on. This cart can fold up to be compact, perfect for storing in your trunk, pantry, or garage.<br/>Three-Height Adjustable Handle: According to the height of the human body, we designed a three-height adjustable handle from 38.5 in to 41.5in, covered with a thicker sponge handle for a more comfortable grip.<br/>Double Basket Design: This shopping cart includes a base basket and a side basket. And you can keep your purse, jacket, umbrella, and other personal smaller items right in front of you for easy access and secure storage.<br/>Versatile Uses: Our customers love using it to transport anything from laundry and groceries to camping gear and gardening tools! With a large basket volume, this cart can accommodate an assortment of objects in varying shapes and sizes. Include storage for sports equipment, beach gear, and kitchen supplies.",
        69.99,
        4,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 34),
    (5, 34),
    (10, 34);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Best Canvas Grocery Shopping Bags",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_35%2Fproduct_035.jpg?alt=media&token=8a6e395f-f1cb-42b9-bbd3-814ca68ccb59",
        "ORGANIC, REUSABLE AND WASHABLE CANVAS GROCERY BAGS: Instead of relying on disposable plastic or paper bags that are bad for the planet, invest in an affordable, and high quality Organic Cotton Reusable Grocery Bag. Unlike other flimsy bags, this is nice and sturdy, and it even has unique bottle sleeves to prevent glass bottles from accidentally banging against each other and breaking. These bags are biodegradable and reusable as well as organic.<br/>STURDY AND PERFECT CANVAS SHOPPING BAGS: The package from Organic Cotton Mart includes three reusable bags so you can fit everything you need. If you prefer, you can also just buy a single one of these reusable bags. Some of the most important features of the bag’s construction include: A large size that is identical to that of a paper bag (14.5” tall, 13” wide, and 8” deep). 6 interior bottle sleeves that pop out Fabric handles which are extra wide and 1.5” by 24” Double stitched top hem<br/>SIMPLE YET STYLISH CLOTH TOTE BAG: The design of the Organic Cotton Mart bags is relatively straightforward, but its shape and dimensions lead to an extreme usefulness. These canvas tote bags have handles which make it very easy to carry your grocery items to your car by leaving the cart at the entrance.<br/>HIGH QUALITY ORGANIC MATERIAL: The material for the bags is 11-ounce Organic Cotton Canvas. This heavy-duty material meets the Global Organic Textile Standards, qualifying it for Ecology and Social Responsibility. This means that the cotton used to create the bags is certified organic, without any processing chemicals, fertilizers, or pesticides like those used in typical cotton. The bags are made in India and made to high standards. This product may not be ideal to do manual screen printing.<br/>EASY TO CARE REUSABLE GROCERY BAGS: These reusable grocery bags are made from 100% natural and unbleached organic cotton. You can easily wash it using your washing machine. Just keep in mind that following the first several washes, the natural bags may seem to be shrunken or excessively wrinkled, which depends on the hardness of your water and your chosen detergent. If this happens, simply pull on the fabric in either direction while the bag is still wet, then let it air dry flat.",
        34.97,
        5,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 35),
    (5, 35),
    (10, 35);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "CleverMade Collapsible Cooler Bag",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_36%2Fproduct_036.jpg?alt=media&token=fdf6d008-1033-4eaa-b641-6748477474bb",
        "Large capacity SnapBasket Tahoe Coolers can hold up to 50 cans of your favorite drinks plus ice; perfect for use at the beach, while camping or to load up full of snacks for youth sports games outdoors<br/>Patented SnapHinges on both sides of the cooler bag offer structured support when the tote is open; to close the cooler, simply push the side hinges in, folding the compact bag down flat<br/>Versatile totes can be packed up for a daytime picnic and are small enough to place in the trunk of your SUV as an ice chest on road trips; collapesed down, the cooler can fit in your suitcase for vacation. Recommended to use with Clever Ice<br/>The perfect size for food delivery services and a great solution to haul groceries from the store or farmer's market to your kitchen at home; comfortable handle and duffel bag handles make toting heavy loads easy<br/>Measures 18.25L x 12.25W x 11.5 when open and collapses flat to 3; weighs 2 pounds when empty; lightweight bag holds 30 liters (8 gallons) by volume with a load capacity of 50 pounds",
        39.99,
        6,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 36),
    (6, 36),
    (10, 36);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "LIVE 2DAY Nice Packs-Thermal Box Liners",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_37%2Fproduct_037.jpg?alt=media&token=dece5cc6-3a38-4b54-b049-39a69f8eecd4",
        "Premium Quality: Our box insulation liners are composed of high-quality, reusable material that is sturdy, lightweight, and reusable. Nice Pack thermal liners can protect food or objects from damage while saving space and money. Thin and leak-proof fabrics inhibit various kinds of heat transmission to provide an outstanding thermal insulation effect.<br/>Unmatched Performance: Our liners allow you to adapt to changing shipping conditions while also saving money. Perishable items such as seafood, meat, eggs, wine, milk, chocolate, ice cream, fruits and vegetables, flowers, films, toners, electronics, medications, and more can be shipped efficiently. These thermal liners insulate coolers and shipping boxes to their maximum capacity, allowing them to work at their best. It takes up 75% less area and weighs less than traditional foam insulation.<br/>Lightweight and cost-effective: It has been tested to last for up to 48 hours. The insulated box lining is designed to maximize space without adding extra weight. They are easy to store and transport and they aid reduce shipping costs while still providing additional protection.<br/>Reusable Insulation Bag: Our top-of-the-line insulation bag is comprised of tough, thin, and leakproof material that resists all forms of heat transmission for great insulation value while saving space and money! This reusable thermal insulating bag is strong, light, flexible, and affordable.<br/>Quality Assurance: Nice Pack is a prominent manufacturer of thermal box liners. Our mission is to supply you with safe, effective, and simple-to-use products. We guarantee a 100% refund if you are unhappy with our products. So what are you waiting for? Go ahead and order your insulated box liners today!<br/>SUPER EASY TO ASSEMBLE AND USE: Take the 2 pieces, folded in a C shape. Cover each side of the carton. See pictures.",
        24.99,
        7,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 37),
    (6, 37),
    (10, 37);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "ROCKBROS Waterproof Bike Bag",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_37%2Fproduct_037.jpg?alt=media&token=dece5cc6-3a38-4b54-b049-39a69f8eecd4",
        "FULLY WATERPROOF FABRIC: This bike pannier bags made with High density 840D Nylon and covered with TPU film which ensure you can use this bag freely on rainy day or wet weather without worrying about your items getting wet inside the bag or scratched. The bag's surface is easy to clean and can be wiped clean with a wet cloth in seconds without fear of muddy roads.<br/>.Max 27L LARGE CAPACITY: Exterior bungee cords (rain jacket,umbrella) + Interior main compartment together with mesh pockets. 27L capacity each bag can holds your change of clothes or some essentials for the cycling trip. The mesh pockets inside the bag can store some small items for easy access. Suitable for multiple occasions like outdoor long distance rides, daily commute or transport groceries.<br/>THREE-POINT ATTACHMENT SYSTEM: Two movable buckles on the back of the bag help you adjust the bag to the right position according to your bike rack.The 360-degree rotatable bracket is used to secure the bag to the side bars to prevent the bag from bouncing out. It can be easily adjusted without additional tools which become a real quick release system.<br/>HUMANIZED DESIGN: The fixing plate on the back of the bag effectively prevents the pannier bag from getting into the bike spokes. Roll up closure design be of more waterproof performance than traditional zippers,and it can help you easily access the personal belongings in the bag.<br/>MORE DETAILS DISPLAY: Reflective logo on both side of bag ensures your night time riding safety. Two round pads at the bottom to reduce friction and protect the panniers.And the bicycle panniers also comes with a comfortable rubber and nylon carrying handle for your convenience.",
        69.99,
        8,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (6, 38),
    (7, 38),
    (10, 38);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "MAYZERO Water, Swim, Hiking, Surf Shoes",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_39%2Fproduct_039.jpg?alt=media&token=15016b93-656c-4db2-8925-02ae8f693b1a",
        "lycra<br/>Rubber sole<br/>Comfortable & Breathable: High quality flexible fabrics uppers are skin-friendly and breathable, which create a cool and cozy environment for your feet. The wide toe gives your toes a more comfortable space to move.<br/>Special Five Toes Design: Thickening Wide Toe Parts can keep your feet from being scratched by sharp objects such as shells or stones when doing water sports. Great lightweight barefoot aqua shoes for men and women.<br/>Durable Rubber Outsole: The upgraded rubber soles with great slip resistance and duration, the convex dots on sole enhances ability of skid resistance, giving strong friction when walking, make each step easy and free.<br/>Quick Dry with Drainage Holes: Increased drain holes at the bottom of beach shoes in outsole to ensure the water flow out of them in time, which creates a cooler and healthier shoes environment, provide you with a super comfortable wearing experience.<br/>Multifunctional Summer Shoes: These unisex multipurpose shoes are suitable for crossfit, trail running, walking, hiking, jogging, trekking, water park, pool, swimming, surfing, beach volleyball, yoga, Pilates, weight training, wake-boarding, sailing, parasailing, boating, kayaking, windsurfing, cycling, fishing, garden, lawn, car-washing and driving etc.",
        26.95,
        9,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (3, 39),
    (6, 39);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Continental Ride Tour Replacement Bike Tire",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_40%2Fproduct_040.jpg?alt=media&token=dc491443-fce5-4442-bf20-6a0a9b2bbb0a",
        "Continuous center tread provides good rolling characteristics and ample traction when cornering<br/>Extra Puncture Belt offers reliable puncture protection<br/>Durable casing and long-lasting tread impress on all rides<br/>Fully ECO, ready for the higher speeds of E-bikes<br/>Low rolling resistance",
        17.07,
        10,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (6, 40),
    (10, 40);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "FUNERICA Cuttable Play Fruits and Veggies",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_41%2Fproduct_41.jpg?alt=media&token=10711a9c-6507-4fc5-b871-4207e2e93771",
        "DESIGNED WITH KIDS IN MIND - FUNERICA Kids Play Food Set is 100% child-friendly as each accessory in this set is made of non-toxic plastic material and tested to meet the US safety standards for toys (ASTM) – free of sharp edges and no choking hazard!<br/>GET BUNCH OF EXTRAS - Aside from the 20 Cutting Pieces Fruits and Vegetables, you will also get a complete mini set of Pretend Kitchen Accessories. These include a grocery shopping basket, a small cooking top, a mini pot, a play knife, a cutting board, plates, cups, and utensils.<br/>FUN LEARNING ACTIVITY - Our Pretend Food Sets for Toddlers are equipped with realistic design and vivid colors. This allows your kids to advance their knowledge about color and shape recognition, spark their creativity, and build their imagination.<br/>COMPACTLY-SIZED - Each Toy Food is smartly-sized to ensure that no small parts can be swallowed by toddlers. The Play Fruits and Veggies are connected by hook-and-loop tabs, which produces a fun crunchy sound when being cut – keeping the kids more engaged in this pretend play.<br/>THE PERFECT GIFT SET - This Kids Kitchen and Grocery Shopping Pretend Playset makes the best gift choice for girls and boys. Its sturdy construction is tested to last even the roughest of kids' gameplays. Our Food Toys are safe, washable, and crush-resistant.",
        19.72,
        1,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 41),
    (7, 41),
    (10, 41);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "FUNERICA Cuttable Play Fruits and Veggies 2",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_42%2Fproduct_042.jpg?alt=media&token=b9f9fa9d-60a8-4bac-91e2-ddfe36234119",
        "Build this adorable local grocery store while learning the power of making new friends and finding creative solutions to benefit everyone<br/>Made from yoga mat material (EVA foam) and high-quality card-stock<br/>Develops children reading skills<br/>The Grocery Store pieces fit together like a 3-D puzzle and fold flat in a portable carrying case, conveniently designed to fit on your bookshelf<br/>",
        24.98,
        2,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 42),
    (7, 42),
    (10, 42);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Learning Resources Canadian Version Teaching Cash Register",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_43%2Fproduct_043.jpg?alt=media&token=f483c0de-56c1-4947-8498-5702daa47c02",
        "Frustration Free Packaging: this version comes in a brown corrugate box. Easy to recycle and great for the environment!<br/>Rewards transactions with lights, sounds and voice messages<br/>Holds actual-size money and includes play coins and bills, coupon and credit card<br/>Features a built-in scanner, scale and coin slot<br/>Helps children practice coin recognition, addition, subtraction and place value with 4 engaging games",
        59.99,
        3,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 43),
    (7, 43),
    (10, 43);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "LeapWard Baby Learning Walker",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_44%2Fproduct_044.jpg?alt=media&token=ccb4c6bc-5c88-4ee5-bc7a-f32dc033ef58",
        "[EASY TO OPERATE] The Learning Walker is easy to operate. Its wheels are non-skid, which roll backward and forward with a handle that is easy to grasp by little hands. It is 15.2” tall upon assembly, making it perfect for kids 12 months and above<br/>[COLORFUL WOODEN PUSH TOY] This colorful alligator push toy is a learning walker with three alligators. The mouths create a click and clack sound when pushed. It also comes with three wooden buggy beads that children can spin and slide<br/>[HELPS TO DEVELOP MULTIPLE SKILLS] This Learning Walker is a beneficial push toy that can enhance the skills of your child. It encourages coordination, gross motor development, and color recognition. Your child can have fun while developing skills<br/>[BEST FOR CHILDHOOD PLAY] The wooden push toy is not just a learning walker. It is an efficient tool for the best childhood play. It was beautifully created and designed with quality and safety in mind making it a good product<br/>[IDEAL GIFT FOR 3+ YEARS ] The Learning Walker is the best gift idea for children ages 3 and above. It also has a hands-on play option for a more enjoyable play experience. It is a high-quality product that can help kids develop skills",
        50.42,
        4,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 44),
    (7, 44),
    (10, 44);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Jenga Game Wooden Blocks Stacking Tumbling Tower",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_45%2Fproduct_045.jpg?alt=media&token=995d95d4-1c7c-4e21-a7d7-ee64bfa82ad3",
        "BLOCK BALANCING GAME: Pull out a block, place it on top, but don't let the tower fall. This fun, challenging game is a great game for families and kids 6 and up<br/>THE ORIGINAL WOOD BLOCK GAME: The Jenga game is the original wood block game that families have loved for generations<br/>GAME FOR 1 OR MORE PLAYERS: No friends around. No problem. Play Jenga solo. Practice stacking skills, building the tower and trying not to let it come tumbling down<br/>TUBE SHAPED BOX: Includes 54 wood blocks and easy-to-use stacking sleeve to help players build the tower. Comes in an easy 'put away' tube-shaped package with a handle for carrying and easy clean up<br/>GREAT PARTY GAME: Liven up a party by bringing out the Jenga game. This classic block stacking game is simple, easy to learn, and makes a great birthday or holiday gift for adults and kids",
        19.99,
        5,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 45),
    (7, 45),
    (10, 45);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Grande Cosmetics GrandeLASH-MD Lash Enhancing Serum",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_46%2Fproduct_046.jpg?alt=media&token=2c46c6c0-dd72-4d1c-872a-0e57170d27f7",
        "Promotes Appearance of Longer, Thicker Eyelashes, Cruelty Free",
        34.00,
        6,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (2, 46),
    (8, 46);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Glo Skin Beauty Oil Free Camouflage Concealer in Natural",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_47%2Fproduct_047.jpg?alt=media&token=0339d78e-7bc9-4192-844b-198150108bb6",
        "CAMOUFLAGE CONCEALER: Effortlessly correct and conceal any imperfection.<br/>CORRECT: Here is your solution to covering an occasional blemish, scarring, hyperpigmentation, or any visible skin condition.<br/>CONCEAL: This oil free concealer contains rich pigments for medium to full coverage, and can be used on all skin types.<br/>CRUELTY-FREE: Glo is committed to responsible behavior, holding true to the highest values and ethical standards in everything we do.<br/>GLO SKIN BEAUTY: Delivering on the promise of healthy, beautiful skin is what drives us every day at Glo Skin Beauty. Our innovative skincare and nourishing mineral makeup collections work together seamlessly to reveal your authentic best.",
        30.00,
        7,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (2, 47),
    (8, 47);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Neutrogena Oil-Free Liquid Eye Makeup Remover",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_48%2Fproduct_048.jpg?alt=media&token=e81df498-a68c-48cb-a606-718dc84490a0",
        "5.5-fluid ounces of Neutrogena Oil-Free Liquid Eye Makeup Remover Solution to gently remove eye makeup without pulling or tugging<br/>Dual-phase oil-free liquid makeup remover effectively helps take off even stubborn waterproof eye makeup like mascara, eyeliner or eye shadow<br/>The lightweight, oil-free formula is non-greasy and contains soothing aloe and cucumber extracts for a refreshing feel with no oily residue<br/>The effective & gentle makeup removing solution is ophthalmologist-tested and developed by dermatologists to be safe for contact lens wearers and gentle for sensitive face and eye area<br/>To use the eye makeup remover, shake well and apply with a cotton pad on closed eyelids, then gently rinse with warm water. These cleansing wipes are the perfect addition to your at-home skincare routine",
        5.82,
        8,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (2, 48),
    (8, 48);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "NYX PROFESSIONAL MAKEUP Butter Gloss",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_49%2Fproduct_049.jpg?alt=media&token=31dd9285-1c2b-45dc-b471-fae9748f9dcc",
        "Butter Gloss: Buttery soft and silky smooth, our decadent Butter Gloss is available in a wide variety of sumptuous shades; Each glossy color delivers sheer to medium coverage that melts onto your lips<br/>Kissable Lips: Our best selling Butter Gloss goes on smooth and creamy and is never sticky, leaving your lips soft, supple and kissable; Try all of our delicious shades, from Angel Food Cake to Tiramisu<br/>Lip Products For The Perfect Pout: Doll your lips in plush, creamy, perfection; Try our complete line of lip products including lipstick, lip gloss, lip cream, lip liner and butter gloss<br/>Cruelty Free Cosmetics: We believe animals belong in our arms, not in a lab; All of our makeup is certified and acknowledged by PETA as a cruelty free brand; We don't test any of our products on animals<br/>Discover NYX PROFESSIONAL MAKEUP: Try all of our professional makeup and beauty products today, from eyeshadow, eyeliner, mascara and false lashes to lipstick, foundation, primer, blush, bronzer, brushes and more",
        4.97,
        9,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (2, 49),
    (8, 49);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Disney Frozen 2 - Townley Girl Cosmetic Compact Set with Mirror",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_50%2Fproduct_050.jpg?alt=media&token=cc01163b-c6e9-4551-9b30-dfbf703e9fff",
        "Safe for children ages 3 years and up: Our non-toxic and water-based formulas make our 14 lip glosses, 4 blushes and 8 eye shadows safe for girls aged 3 years and older. They are non-mess as they wash out with water!<br/>14 lip gloss colors: This set includes 14 shimmery lip gloss colors, including purple, orange, red, magenta, blue, and pink. All colors apply a shimmery look to lips. Flavors include bubble gum and cotton candy.<br/>4 blush colors: Blush shades include: Light pink, darker pink, blush and peach.<br/>8 eye shadow colors: This set includes 8 eye shadow colors, including eye shadow creams and eye shadow powders! Eye shadow powder colors include: Blue, yellow, green, light blue, white, red, purple and light pink.<br/>More fun for everyone: This ultimate makeover set is the perfect activity that she can share in with her friends at sleepovers, makeup parties, birthday parties and more!",
        11.89,
        10,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (2, 50),
    (7, 50),
    (8, 50);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "SUNEE Plastic Mesh Zipper Pouch",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_51%2Fproduct_051.jpg?alt=media&token=315128cd-7c31-403b-917d-623fb8c1f247",
        "【PACKAGE CONTAINS】 - You will get a set of 18 Packs 9x13 inches multi-colored plastic zipper pouches for the most paper size of letter-size prints or smaller document storage. It can help you organize your miscellaneous items to meet your daily life and work.<br/>【DURABLE & PORTABLE】 - SUNEE zipper file bags are made of thick vinyl material, water-resistant, moisture-resistant. Each metal zipper is equipped with a rope loop, which is strong and durable. It can be used as a hanging ring and ready to hang.<br/>【APPROPRIATE TRANSPARENCY DESIGN】 - SUNEE zip pouches with moderate transparency prevent from revealing your important papers' privacy, but still can identify what the stuff in the bags. Easily classify the various items, storing in your backpack and travel bag, and quickly get what you need.<br/>【WIDESPREAD USE FOR STORAGE】 - The clear zippered pouch specially designed for everyone's storage needs. PERFECT for storing important papers, devices, smaller books and others.<br/>【SIMPLY SORTING YOUR ITEMS】 - Make it easy to organize and classify items of various shapes at work and home, Such as puzzles & games scattered. Great for office supplies and school supplies.",
        14.99,
        1,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 51),
    (9, 51);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "VITESSE 55 inch Gaming Desk",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_52%2Fproduct_052.jpg?alt=media&token=9702338b-fc1d-4c51-91f2-019fea9326cd",
        "[Gaming Handle Rack]: Comes with a rack where you can place a couple of controllers and games for convenience. All your gaming tears are near by your hand.<br/>[Full Mouse Pad Top ]: Further upgraded the desktop, 55.1”L×23.6”W extra large desktop provides more space. The mouse pad covers the entire surface, so don’t have to worry about running out of surface space or your mouse and keyboard being uneven in height.<br/>[Support for Dual Monitors ]: Constructed via a premium density fiberboard and a coated steel frame. Ensuring stability whilst you game. You can put 2 monitors here and a bunch of accessories without the fear of it collapsing. T-shaped design and four leveling feet to make sure the desk to keep horizontal.<br/>[Cup Holder and Headphone Hook]: The last thing you want is to spill water all over your expensive electronics, that’s why this desk comes with a cup holder. It’s an arm reach away and can fit small and large cups, even use it to put ice cream in. Also comes with headphone hook.<br/>[12 Month Service]: Free replacement or parts guarantee for any quality problem within 365 days. Reply in 24 hours for any problems.",
        7.99,
        2,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 52),
    (7, 52),
(9, 52);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Office Chair, Executive Racing Game Chair",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_53%2Fproduct_053.jpg?alt=media&token=4d280393-8c62-4713-9487-904274bab0ec",
        "Get a fantastic experience from soft armrests<br/>Rocking chair back and forth from 90° to 120°<br/>360° swivel the chair if you want to change your direction but stay in the same place<br/>Move the chair around in your home office with 360° smooth-rolling casters<br/>Offer maximum load of 250 lbs with durable and stable chair base offer",
        99.99,
        3,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 53),
    (7, 53),
(9, 53);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Ukonic Minecraft Glowstone Tripod Floor Lamp",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_54%2Fproduct_054.jpg?alt=media&token=a1b8828b-c504-47a2-9bfa-e60172fd8443",
        "Prepare For Adventure: We mined this light-source block especially for you. Inspired by the popular video game Minecraft, this tripod-style electric floor lamp features a game-authentic Glowstone lamp shade.<br/>Floor To Ceiling Minecraft Fun: Build your perfect space with home decor mined from The Nether. This 62-inch statement piece makes a great addition to any kid's bedroom, teen's dorm room, or adult fan's gaming space.<br/>AC Powered: Floor lamp operates via a polarized electric plug with a convenient in-line on/off switch. Uses incandescent or energy-efficient LED light bulb with a standard E26 base to illuminate your living space.<br/>Easy To Assemble: Block by block, you can build your perfect space in no time with this tripod-style standing lamp. The simple assembly process allows for a convenient, hassle-free setup. No tools needed!<br/>Building Blocks Of Fandom: The pixel-perfect world of Minecraft comes to life with this officially licensed Glowstone floor lamp. Perfect for avid gamers looking to level up their home decor with a geeky twist.",
        59.99,
        4,
        FALSE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (4, 54),
    (7, 54),
(9, 54);

INSERT INTO
    Product(
        name,
        img_url,
        description,
        price,
        createdBy,
        isOnSale
    )
VALUES
    (
        "Amazon Basics Retractable Bal23456791012345point Pen - Black",
        "https://firebasestorage.googleapis.com/v0/b/ecommerce-eb6bf.appspot.com/o/product%2Fproduct_55%2Fproduct_055.jpg?alt=media&token=7ac7dc3c-2b3a-4440-a521-65a9a0fefe3d",
        "Conforms to ASTM D4236<br/>JIS S 6039 Ball point pen H B<br/>Ball point pen ISO 12757-1 H B<br/>Product Dimensions: 5.71 x 0.39 x 0.55 inches (LxWxH); 1.2mm point",
        7.40,
        5,
        TRUE
    );

INSERT INTO
    CategoryProduct(category_id, product_id)
VALUES
    (9, 55),
    (10, 55);

INSERT INTO
    Rate(score, product_id, account_id)
VALUES
    (5, 1, 1),
    (2, 1, 2),
    (3, 2, 1);

INSERT INTO
    Post(content, product_id, account_id)
VALUES
    ("I like this one", 1, 1),
    ("I like this one", 2, 1),
    ("I like this one", 1, 2),
    ("I like this one", 1, 2),
    ("I like this one", 3, 1);    

INSERT INTO
    Comment(content, post_id, account_id)
VALUES
    ("me, too", 1, 2),
    ("me, too", 2, 2),
    ("me, too", 1, 1),
    ("me, too", 3, 1);

INSERT INTO
    PostLike(post_id, account_id)
VALUES
    (1, 2),
    (2, 2),
    (1, 1),
    (3, 1);

INSERT INTO
    CommentLike(comment_id, account_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 1),
    (4, 1),
    (3, 2);    

INSERT INTO
    Blog(content, account_id)
VALUES
    ("This is the sample blog 1.", 1);

INSERT INTO
    Blog(content, account_id, img_url)
VALUES
    (
        "This is the sample blog 2.",
        1,
        "/images/blogs/blog_example.jpg"
    );

INSERT INTO
    Blog(content, account_id)
VALUES
    ("This is the sample blog 3.", 2);

INSERT INTO
    Blog(content, account_id, img_url)
VALUES
    (
        "This is the sample blog 4.",
        2,
        "/images/blogs/blog_example.jpg"
    );  

INSERT INTO
    BlogLike(blog_id, account_id)
VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (3, 1),
    (3, 2);

INSERT INTO
    BlogComment(content, blog_id, account_id)
VALUES
    ("I agree", 1, 1),
    ("I agree", 1, 2),
    ("I agree", 2, 1),
    ("I agree", 3, 1),
    ("I agree", 3, 2);    

INSERT INTO
    BlogCommentLike(blog_comment_id, account_id)
VALUES
    (1, 1),
    (1, 2),
    (3, 1);

INSERT INTO
    MyOrder(account_id, session_id)
VALUES
    (1, "session_id_0001");

INSERT INTO
    OrderProduct(quantity, product_id, order_id, payment)
VALUES
    (10, 1, 1, "Succeeded"),
    (5, 2, 1, "Succeeded"),
    (20, 3, 1, "Succeeded");

INSERT INTO
    MyOrder(account_id, session_id)
VALUES
    (2, "session_id_0002");

INSERT INTO
    OrderProduct(quantity, product_id, order_id, payment)
VALUES
    (35, 2, 2, "Succeeded"),
    (40, 3, 2, "Succeeded");
       
INSERT INTO
    Favorite(product_id, account_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 1);

