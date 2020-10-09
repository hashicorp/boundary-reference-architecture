// +build integration

package e2e

import (
	"fmt"
	"os"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAWS(t *testing.T) {
	if os.Getenv("BOUNDARY_INTEGRATION_AWS") == "" {
		t.Skip("skipping AWS integration test")
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "terraform/aws",
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	boundaryAddr := fmt.Sprintf("%s:9200", terraform.Output(t, terraformOptions, "boundary_addr"))

	code := 0
	for {
		code, _ = http_helper.HttpGet(t, boundaryAddr, nil)
		if code == 200 {
			break
		}

		fmt.Printf("boundary is not available at %s yet, retrying in 2s...\n", boundaryAddr)
		time.Sleep(time.Second * 2)
	}

	os.Setenv("BOUNDARY_ADDR", boundaryAddr)
	//assert.NotEmpty(t, login(t))

	//	TestAccount_HappyPath(t)
}
