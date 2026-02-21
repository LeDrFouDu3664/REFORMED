import os
import discord
from discord.ext import commands
import logging
from dotenv import load_dotenv
import config

load_dotenv()

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('discord_bot')

class DiscordBot(commands.Bot):
    def __init__(self):
        intents = discord.Intents.default()
        intents.members = True
        intents.message_content = True

        super().__init__(
            command_prefix="!",
            intents=intents,
            help_command=None
        )

    async def setup_hook(self):
        # Initialize database
        from utils import db
        await db.init_db()

        # Load extensions
        for filename in os.listdir('./cogs'):
            if filename.endswith('.py') and not filename.startswith('__'):
                try:
                    await self.load_extension(f'cogs.{filename[:-3]}')
                    logger.info(f'Loaded extension {filename}')
                except Exception as e:
                    logger.error(f'Failed to load extension {filename}: {e}')

        # Sync slash commands
        try:
            guild = discord.Object(id=config.GUILD_ID)
            self.tree.copy_global_to(guild=guild)
            await self.tree.sync(guild=guild)
            logger.info("Synced slash commands for the guild.")
        except Exception as e:
            logger.error(f"Failed to sync slash commands: {e}")

    async def on_ready(self):
        logger.info(f'Logged in as {self.user} (ID: {self.user.id})')
        logger.info('------')

if __name__ == "__main__":
    bot = DiscordBot()
    if config.TOKEN:
        bot.run(config.TOKEN)
    else:
        logger.error("No token found in environment variables or config.py")
