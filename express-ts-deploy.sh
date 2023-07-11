#!/bin/bash 

FILE="index.ts"
APP="$1"
json_file="package.json"
ts_json_file="tsconfig.json"

CODE="
import express, {Express, Request, Response} from 'express';
import cors from 'cors';
import {config} from 'dotenv';

config();

const PORT: number = 3001;

const app: Express = express();
app.use(cors());
app.use(express.json())
app.use(express.urlencoded({extended: true}))

app.get('/', (req: Request,res: Response) => {
    res.status(200).send('hello world');
});

app.listen(PORT, () => console.log(\`Server has been started on port: \${PORT}\`));
"

DATA_FOR_TSCONFIG="{
    \"compilerOptions\": {
        \"target\": \"es2016\",
        \"module\": \"commonjs\",
        \"strict\": true,
        \"esModuleInterop\": true,
        \"skipLibCheck\": true,
        \"forceConsistentCasingInFileNames\": true,
        \"outDir\": \"./dist\"
    }
}
"

if [ -z $APP ]; then
    echo "Please create directory for project! Write name of directory!"
    exit 1
fi

if [ -d $APP ]; then
    echo "This directory already exists!"
    rm -rf "$APP"
fi

mkdir "$APP"
cd "$APP" || exit
npm init -y
touch "$FILE"

echo "Downloading dependencies..."
cat << EOF 
-----------------------------------------
EOF
npm i typescript
npm i -D nodemon
npm i express cors fs dotenv
npm i -D typescript @types/node @types/express @types/cors @types/dotenv
npx tsc --init

cat << EOF
------------------------------------------
EOF

json_data=$(cat "$json_file")
ts_json_data=$(cat "$ts_json_file")

new_json_data=$(echo "$json_data" | sed '/"main": "index.js",/a\ \ \ \"type\": \"module\",' | sed 's/"test": "echo \\"Error: no test specified\\" && exit 1"/"test": "echo \\"Error: no test specified\\" \&\& exit 1",/' | sed '/"test": "echo \\"Error: no test specified\\" && exit 1",/a\ \ \ \"build\": \"npx tsc\",\n\ \ \ \"start\": \"node dist/index.js\",\n\ \ \ \"dev\": \"concurrently \\"npx tsc --watch\\" \\"nodemon -q dist/index.js\\"\"')

echo "$new_json_data" > "$json_file"

echo "$DATA_FOR_TSCONFIG" > "$ts_json_file"

echo -e "$CODE" >> "$FILE"

echo "First building app..."
cat << EOF
------------------------------------------
EOF
npm run build
cat << EOF
------------------------------------------
EOF
