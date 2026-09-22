import subprocess
import json

active_ws_data = subprocess.check_output(["hyprctl", "-j", "activeworkspace"])
active_ws = json.loads(active_ws_data)

ws_id = str(active_ws["id"])
current_layout = active_ws.get("tiledLayout", "")

new_layout = "dwindle" if current_layout == "scrolling" else "scrolling"

eval_command = f"hl.workspace_rule({{ workspace = '{ws_id}', layout = '{new_layout}' }})"
subprocess.run(["hyprctl", "eval", eval_command])