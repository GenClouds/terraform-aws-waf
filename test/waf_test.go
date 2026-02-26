package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMinimalWAF(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/minimal",
		NoColor:      true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	webAclID := terraform.Output(t, terraformOptions, "web_acl_id")
	webAclArn := terraform.Output(t, terraformOptions, "web_acl_arn")

	assert.NotEmpty(t, webAclID)
	assert.NotEmpty(t, webAclArn)
	assert.Contains(t, webAclArn, "arn:aws:wafv2")
}

func TestSimpleRulesDSL(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/simple-rules",
		NoColor:      true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	webAclID := terraform.Output(t, terraformOptions, "web_acl_id")
	assert.NotEmpty(t, webAclID)
}

func TestPresetConfiguration(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/preset-api-hardened",
		NoColor:      true,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	webAclID := terraform.Output(t, terraformOptions, "web_acl_id")
	assert.NotEmpty(t, webAclID)
}
