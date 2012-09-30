
_craft_stream_service = nil

def stream_manager
  _craft_stream_service ||= CraftStreamService.instance
end