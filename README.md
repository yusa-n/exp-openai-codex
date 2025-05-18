experimental project for openai codex

## Scripts

- `scripts/cargo_workspace_graph.sh` - generate a Mermaid `graph TD` dependency graph for a Cargo workspace.

### Example

```
./scripts/cargo_workspace_graph.sh example-workspace
```

The output for `example-workspace` shows `crate_b` depending on `crate_a`.
