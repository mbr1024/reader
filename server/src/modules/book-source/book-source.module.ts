import { Module } from '@nestjs/common';
import { BookSourceController } from './book-source.controller';
import { BookSourceService } from './book-source.service';
import { ZhuishuSource } from './sources/zhuishu.source';
import { BiqugeSource } from './sources/biquge.source';
import { DemoSource } from './sources/demo.source';
import { FanqieSource } from './sources/fanqie.source';
import { LegadoSourceParser } from './services/legado-parser.service';

@Module({
  controllers: [BookSourceController],
  providers: [
    BookSourceService,
    DemoSource,
    ZhuishuSource,
    BiqugeSource,
    FanqieSource,
    LegadoSourceParser,
  ],
  exports: [BookSourceService],
})
export class BookSourceModule {}
