from django.test import TestCase, Client
from django.urls import reverse
from accueil.models import ServerRule, Streamer, ShopPackage, VoteSite


class HorizonRPViewsTestCase(TestCase):
    def setUp(self):
        self.client = Client()
        self.rule = ServerRule.objects.create(
            number="01",
            title="Respect",
            content="Respect obligatoire",
            order=1,
            is_active=True
        )
        self.streamer = Streamer.objects.create(
            name="StreamerTest",
            platform="Twitch",
            channel_url="https://twitch.tv/test",
            is_live=True
        )
        self.package = ShopPackage.objects.create(
            name="VIP Test",
            price=19.99,
            description="Super pack",
            features="Avantage 1\nAvantage 2"
        )
        self.vote_site = VoteSite.objects.create(
            name="Top Vote",
            url="https://top.vote",
            reward_description="1000$"
        )

    def test_accueil_page(self):
        response = self.client.get(reverse('accueil:accueil'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "HORIZON RP")
        self.assertContains(response, "VIP Test")

    def test_reglement_page(self):
        response = self.client.get(reverse('accueil:reglement'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "01. Respect")
        self.assertContains(response, "Respect obligatoire")

    def test_boutique_page(self):
        response = self.client.get(reverse('accueil:boutique'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "VIP Test")
        # In French locale, 19.99 is rendered as 19,99 €
        self.assertContains(response, "19,99")
        self.assertContains(response, "Avantage 1")

    def test_streamers_page(self):
        response = self.client.get(reverse('accueil:streamers'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "StreamerTest")
        self.assertContains(response, "EN DIRECT")

    def test_vote_page(self):
        response = self.client.get(reverse('accueil:vote'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Top Vote")
        self.assertContains(response, "1000$")

    def test_dashboard_page(self):
        response = self.client.get(reverse('accueil:dashboard'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Horizon RP")
        self.assertContains(response, "Cfx.re")


class HorizonRPModelsTestCase(TestCase):
    def test_server_rule_str(self):
        rule = ServerRule(number="05", title="Vocal RP")
        self.assertEqual(str(rule), "05. Vocal RP")

    def test_shop_package_features(self):
        package = ShopPackage(name="VIP", price=10.0, features="Feat 1\n  Feat 2  \n\n")
        self.assertEqual(package.features_list(), ["Feat 1", "Feat 2"])
        self.assertEqual(str(package), "VIP - 10.0€")

    def test_streamer_and_vote_str(self):
        streamer = Streamer(name="PlayerOne")
        vote_site = VoteSite(name="RP-Vote")
        self.assertEqual(str(streamer), "PlayerOne")
        self.assertEqual(str(vote_site), "RP-Vote")
