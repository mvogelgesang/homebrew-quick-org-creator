# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class QuickOrgCreator < Formula
  desc "A script to ease the process of creating Salesforce scratch orgs"
  homepage "https://github.com/mvogelgesang/homebrew-quick-org-creator"
  url "https://github.com/mvogelgesang/homebrew-quick-org-creator/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "2ca040070a0c0b932cc088cae715c079896404650464f21de9f44ad2a08a9b4b"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    bin.install "src/run.sh" => "oc"
  end

  test do
    system "#{bin}/oc", "namespace"
  end
end
