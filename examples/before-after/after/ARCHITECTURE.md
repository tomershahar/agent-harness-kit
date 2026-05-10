# Architecture — example-app

## System Overview

A minimal Node.js application that prints output to stdout. No framework, no database, no services.

## Layer Diagram

```
src/index.js  →  stdout
```

## Data Flow

1. Node.js executes src/index.js
2. console.log writes to stdout
3. Process exits 0

## Storage Layout

No persistent storage — stateless application.
