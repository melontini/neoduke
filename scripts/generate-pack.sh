mkdir -p output

META_JSON="{\"metaVersion\": 2, \"host\": \"@wetdry.world\", \"exportedAt\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", \"emojis\": []}"

EMOJI_ARRAY=$(mktemp)
echo "$META_JSON" | jq . > "$EMOJI_ARRAY"

for FILE in x256/*.png; do
  [ -e "$FILE" ] || continue

  FILE_NAME=$(basename "$FILE")
  FILE_BASE=${FILE_NAME%.png}

  EMOJI_ENTRY=$(jq -n \
    --arg fileName "$FILE_NAME" \
    --arg name "$FILE_BASE" \
    '{
      downloaded: true,
      fileName: $fileName,
      emoji: {
        name: $name,
        category: "neoduke",
        license: "CC BY-NC-SA 4.0",
        aliases: []
      }
    }')

  jq --argjson emojiEntry "$EMOJI_ENTRY" '.emojis += [$emojiEntry]' "$EMOJI_ARRAY" > tmp.json && mv tmp.json "$EMOJI_ARRAY"

  cp "$FILE" "output/$FILE_NAME"
done

mv "$EMOJI_ARRAY" "output/meta.json"
cp "LICENSE.txt" "output/LICENSE.txt"