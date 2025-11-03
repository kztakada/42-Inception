import * as fs from 'fs';
import * as path from 'path';

// --- 1. ショーケース用のデータ定義 ---
interface ShowcaseItem {
    id: string;
    title: string;
    description: string;
    imageFile: string; // ここはファイル名 (例: 'project-alpha.png')
}

const siteData = {
    title: "Special Fruit Showcase",
    heading: "スペシャルフルーツショーケース",
    items: [
        {
            id: "p1",
            title: "いちご🍓",
            description: "収穫時期：春から初夏。新鮮で甘いイチゴをお楽しみください。",
            imageFile: "strawberry.png"
        },
        {
            id: "p2",
            title: "メロン🍈",
            description: "収穫時期：初夏。甘くてジューシーなメロンをお楽しみください。",
            imageFile: "melon.png"
        },
        {
            id: "p3",
            title: "ぶどう🍇",
            description: "収穫時期：秋。甘くてジューシーなぶどうをお楽しみください。",
            imageFile: "grape.png"
        }
    ] as ShowcaseItem[]
};

// --- 2. ショーケースアイテムのHTMLを生成する関数 ---
function generateItemCards(items: ShowcaseItem[]): string {
    return items.map(item => {
        // index.htmlから見て ./images/ファイル名 になるようパスを指定
        const imagePath = `./images/${item.imageFile}`;
        
        return `
        <div class="card" id="${item.id}">
            <img src="${imagePath}" alt="${item.title}">
            <div class="card-content">
                <h2>${item.title}</h2>
                <p>${item.description}</p>
            </div>
        </div>
        `;
    }).join('\n');
}

// --- 3. メインの生成関数 (画像コピー処理を追加) ---
function buildStaticPage() {
    console.log("[INFO] 静的ページのビルドを開始します...");

    try {
        // --- 3a. 各種パスの定義 ---
        const templatePath = path.join(__dirname, 'template.html');
        const cssPath = path.join(__dirname, 'style.css');
        const sourceImagesDir = path.join(__dirname, 'images'); // コピー元のimages
        
        const outputDir = path.join(__dirname, 'dist');
        const outputFilePath = path.join(outputDir, 'index.html');
        const outputImagesDir = path.join(outputDir, 'images'); // コピー先のimages

        // --- 3b. 出力先ディレクトリの準備 ---
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }

        // --- 3c. テンプレートとCSSの読み込み ---
        let templateHtml = fs.readFileSync(templatePath, 'utf8');
        const styleCss = fs.readFileSync(cssPath, 'utf8');

        // --- 3d. コンテンツの生成 ---
        const itemCardsHtml = generateItemCards(siteData.items);
        const generatedDate = new Date().toLocaleString('ja-JP');

        // --- 3e. プレースホルダーを実際のコンテンツで置換 ---
        let outputHtml = templateHtml
            .replace('<!--TITLE-->', siteData.title)
            .replace('<!--MAIN_HEADING-->', siteData.heading)
            .replace('<!--STYLES-->', `<style>\n${styleCss}\n</style>`)
            .replace('<!--SHOWCASE_ITEMS-->', itemCardsHtml)
            .replace('<!--GENERATED_DATE-->', generatedDate);

        // --- 3f. HTMLファイルの書き出し ---
        fs.writeFileSync(outputFilePath, outputHtml, 'utf8');
        console.log(`[SUCCESS] HTMLページが生成されました: ${outputFilePath}`);

        // --- 3g. ★重要: images フォルダを dist にコピー ---
        if (fs.existsSync(sourceImagesDir)) {
            // コピー先の images ディレクトリがなければ作成
            if (!fs.existsSync(outputImagesDir)) {
                fs.mkdirSync(outputImagesDir, { recursive: true });
            }
            // fs.cpSync を使ってフォルダを再帰的にコピー (Node.js v16.7.0+)
            fs.cpSync(sourceImagesDir, outputImagesDir, { recursive: true });
            console.log(`[INFO] 'images' フォルダを '${outputDir}' にコピーしました。`);
        } else {
            console.warn(`[WARN] 'images' フォルダが見つかりません。画像はコピーされませんでした。`);
        }

        console.log(`[SUCCESS] ビルドが完了しました。`);

    } catch (err) {
        console.error("[ERROR] ページの生成に失敗しました:", err);
    }
}

// --- 4. スクリプトの実行 ---
buildStaticPage();