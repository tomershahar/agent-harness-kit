{
  "project": "{{PROJECT_NAME}}",
  "description": "{{PROJECT_DESCRIPTION}}",
  "schema": {
    "status_values": ["not_started", "active", "blocked", "passing"],
    "required_fields": ["id", "name", "behavior", "verification", "status"]
  },
  "features": [
    {
      "id": "F01",
      "name": "{{FEATURE_1_NAME}}",
      "behavior": "{{FEATURE_1_BEHAVIOR}}",
      "verification": "{{FEATURE_1_VERIFICATION_COMMAND}}",
      "status": "not_started",
      "evidence": null,
      "testedAt": null
    }
  ]
}
