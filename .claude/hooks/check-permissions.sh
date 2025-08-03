#!/bin/bash

# Claude CodeのPreToolUseフックとして機能し、
# tmuxのセッション名に基づいてコマンドの実行を動的に制御する。

# スクリプトが失敗した場合に即座に終了する
set -euo pipefail

# --------------------------------------------------------------------------------
# 1. 現在のtmuxセッション名からエージェントの役割を取得する
# --------------------------------------------------------------------------------

SESSION_NAME=$(tmux display-message -p '#S')

ROLE=$(echo "$SESSION_NAME" | sed -E 's/.*-(po|manager|dev[1-4])$/\1/')

if [ -z "$ROLE" ]; then
    # 役割が抽出できなかった場合はブロック
    echo "{\"decision\":\"block\",\"reason\":\"未定義のセッション名です。セッション名に役割（-po, -manager, -dev1など）を含めてください。\"}"
    exit 0
fi

# --------------------------------------------------------------------------------
# 2. 実行しようとしているツールとコマンドを解析する
# --------------------------------------------------------------------------------

TOOL_NAME=$(jq -r '.tool_name')
TOOL_INPUT_COMMAND=$(jq -r '.tool_input.command // "N/A"')

# --------------------------------------------------------------------------------
# 3. 役割とコマンドを照合して実行可否を判断し、委任メッセージを生成する
# --------------------------------------------------------------------------------

case "$ROLE" in
    "po")
        # po.mdの禁止事項と許可事項をチェック
        # bashはsend-agentのみを許可

            # 許可されていない他のツールはすべてブロック
        case "$TOOL_NAME" in
            "Read"|"Glob"|"Grep"|"Write"|"Edit"|"MultiEdit"|"NotebookEdit"|"Task"|"LS")
                DELEGATE_MESSAGE=$(cat <<EOF
POは作業を行いません。managerに委任します。
以下のコマンドをコピーして実行してください。

SESSION_NAME=$(tmux display-message -p '#S')
send-agent --session \$SESSION_NAME manager "【緊急委任】
POが実行しようとしていた作業を委任します。
作業内容：[ツール名: ${TOOL_NAME}, コマンド: ${TOOL_INPUT_COMMAND}]
指示：この作業を適切なdevに割り当てて実行してください。"
EOF
)
                echo "{\"decision\":\"block\",\"reason\":${DELEGATE_MESSAGE}}"
                exit 0
                ;;
        esac

        # Bashコマンドのホワイトリスト（情報収集とsend-agentのみ）
        if [ "$TOOL_NAME" == "Bash" ]; then
            case "$TOOL_INPUT_COMMAND" in
                "ls"*|"git status"*|"cat"*|"grep"*|"find"*|"echo"*|"pwd"*)
                    # 許可
                    ;;
                "send-agent"*)
                    # managerはsend-agentコマンドの実行を許可
                    ;;
                *)
                    DELEGATE_MESSAGE=$(cat <<EOF
POは作業を行いません。managerに委任します。
Bashで作業をしようとしていた場合は，以下のコマンドをコピーして実行してください。

SESSION_NAME=$(tmux display-message -p '#S')
send-agent --session \$SESSION_NAME manager "【緊急委任】
POが実行しようとしていた作業を委任します。
作業内容：[ツール名: ${TOOL_NAME}, コマンド: ${TOOL_INPUT_COMMAND}]
指示：この作業を適切なdevに割り当てて実行してください。"
EOF
)
                    echo "{\"decision\":\"block\",\"reason\":${DELEGATE_MESSAGE}}"
                    exit 0
                    ;;
            esac
        fi
        ;;

    "manager")
        # manager.mdの禁止事項をチェック
        case "$TOOL_NAME" in
            "Write"|"Edit"|"MultiEdit"|"NotebookEdit")
                DELEGATE_MESSAGE=$(cat <<EOF
Managerは作業を行いません。devに委任します。
以下のコマンドをコピーして実行してください。

SESSION_NAME=$(tmux display-message -p '#S')
send-agent --session \$SESSION_NAME dev1 "【緊急委任】
Managerが実行しようとしていた作業を委任します。
作業内容：[ツール名: ${TOOL_NAME}, コマンド: ${TOOL_INPUT_COMMAND}]
指示：この作業を完了して報告してください。"
EOF
)
                echo "{\"decision\":\"block\",\"reason\":${DELEGATE_MESSAGE}}"
                exit 0
                ;;
        esac

        # Bashコマンドのホワイトリスト（情報収集とsend-agentのみ）
        if [ "$TOOL_NAME" == "Bash" ]; then
            case "$TOOL_INPUT_COMMAND" in
                "ls"*|"git status"*|"cat"*|"grep"*|"find"*|"echo"*|"pwd"*)
                    # 許可
                    ;;
                "send-agent"*)
                    # managerはsend-agentコマンドの実行を許可
                    ;;
                *)
                    DELEGATE_MESSAGE=$(cat <<EOF
Managerは作業を行いません。devに委任します。
Bashで作業をしようとしていた場合は，以下のコマンドをコピーして実行してください。

SESSION_NAME=$(tmux display-message -p '#S')
send-agent --session \$SESSION_NAME dev1 "【緊急委任】
Managerが実行しようとしていた作業を委任します。
作業内容：[ツール名: ${TOOL_NAME}, コマンド: ${TOOL_INPUT_COMMAND}]
指示：この作業を完了して報告してください。"
EOF
)
                    echo "{\"decision\":\"block\",\"reason\":${DELEGATE_MESSAGE}}"
                    exit 0
                    ;;
                    echo "{\"decision\":\"block\",\"reason\":\"Managerは情報収集以外のBashコマンドは実行できません。\"}"
                    exit 0
                    ;;
            esac
        fi
        ;;

    "dev"|"dev"*)
        # 開発者は基本的に全ツールを許可
        ;;

    *)
        # 未定義の役割はブロック
        echo "{\"decision\":\"block\",\"reason\":\"未定義の役割: ${ROLE}\"}"
        exit 0
        ;;
esac

# ここまでブロックされなければ許可
echo "{}"