
CRAFT_STREAMS = nil

def stream_manager
  CRAFT_STREAMS ||= CraftStreamService.instance
end