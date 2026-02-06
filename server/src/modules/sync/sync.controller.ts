import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { SyncService } from './sync.service';
import { SyncRequestDto } from './dto/sync.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('sync')
@UseGuards(JwtAuthGuard)
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  // 执行同步
  @Post()
  sync(@Request() req, @Body() dto: SyncRequestDto) {
    return this.syncService.sync(req.user.id, dto);
  }

  // 获取上次同步信息
  @Get('last')
  getLastSync(@Request() req, @Query('deviceId') deviceId?: string) {
    return this.syncService.getLastSync(req.user.id, deviceId);
  }

  // 获取完整同步数据 (新设备首次同步)
  @Get('full')
  getFullSyncData(@Request() req) {
    return this.syncService.getFullSyncData(req.user.id);
  }
}
