from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dashboard', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='hospital',
            name='password',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
