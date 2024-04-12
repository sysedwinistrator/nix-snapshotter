package nix

import (
	"context"
	"testing"
)

func TestGetNixStorePath(t *testing.T) {
	ctx := context.Background()

	// Single arch ref
	ref := "nix:0/nix/store/02zg1wk37s9k35n5iv850g52dp1ffdxz-nginx-1.24.0"
	expected := "/nix/store/02zg1wk37s9k35n5iv850g52dp1ffdxz-nginx-1.24.0"
	received := getNixStorePath(ctx, ref, "x86_64-linux")
	if received != expected {
		t.Fatalf("Expected %s, received %s", expected, received)
	}

	// Multi arch ref
	ref = "nix:0/multiarch/x86_64-linux/nix/store/02zg1wk37s9k35n5iv850g52dp1ffdxz-nginx-1.24.0/aarch64-linux/nix/store/gjilixzvxk9pzilz3ixxamrjqk4mk1jl-nginx-1.24.0"

	expected = "/nix/store/02zg1wk37s9k35n5iv850g52dp1ffdxz-nginx-1.24.0"
	received = getNixStorePath(ctx, ref, "x86_64-linux")
	if received != expected {
		t.Fatalf("Expected %s, received %s", expected, received)
	}

	expected = "/nix/store/gjilixzvxk9pzilz3ixxamrjqk4mk1jl-nginx-1.24.0"
	received = getNixStorePath(ctx, ref, "aarch64-linux")
	if received != expected {
		t.Fatalf("Expected %s, received %s", expected, received)
	}
}
